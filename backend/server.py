from fastapi import FastAPI, APIRouter, HTTPException
from dotenv import load_dotenv
from starlette.middleware.cors import CORSMiddleware
from motor.motor_asyncio import AsyncIOMotorClient
import os
import logging
from pathlib import Path
from pydantic import BaseModel, Field
from typing import List, Optional
import uuid
from datetime import datetime
import base64

# Import the emergentintegrations
from emergentintegrations.llm.chat import LlmChat, UserMessage
from emergentintegrations.llm.gemeni.image_generation import GeminiImageGeneration

ROOT_DIR = Path(__file__).parent
load_dotenv(ROOT_DIR / '.env')

# MongoDB connection
mongo_url = os.environ['MONGO_URL']
client = AsyncIOMotorClient(mongo_url)
db = client[os.environ['DB_NAME']]

# Gemini API key
GEMINI_API_KEY = os.environ['GEMINI_API_KEY']

# Create the main app without a prefix
app = FastAPI()

# Create a router with the /api prefix
api_router = APIRouter(prefix="/api")

# Define Models
class Ingredient(BaseModel):
    name: str
    quantity: Optional[str] = None

class Recipe(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    title: str
    description: str
    ingredients: List[str]
    instructions: List[str]
    cuisine: Optional[str] = None
    diet_type: Optional[str] = None
    prep_time: Optional[str] = None
    cook_time: Optional[str] = None
    servings: Optional[int] = None
    image_base64: Optional[str] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)

class RecipeRequest(BaseModel):
    ingredients: List[str]
    diet_type: Optional[str] = None
    cuisine: Optional[str] = None

class GeneratedImage(BaseModel):
    recipe_id: str
    image_base64: str
    created_at: datetime = Field(default_factory=datetime.utcnow)

# Add your routes to the router
@api_router.get("/")
async def root():
    return {"message": "Welcome to Cravyn - Your AI Recipe Discovery App"}

@api_router.post("/recipes/generate", response_model=Recipe)
async def generate_recipe(request: RecipeRequest):
    try:
        # Create prompt for Gemini
        ingredients_str = ", ".join(request.ingredients)
        diet_filter = f" that is {request.diet_type}" if request.diet_type else ""
        cuisine_filter = f" from {request.cuisine} cuisine" if request.cuisine else ""
        
        prompt = f"""Create a detailed recipe using these ingredients: {ingredients_str}. 
        The recipe should be{diet_filter}{cuisine_filter}.
        
        Please format your response as a JSON object with these exact fields:
        - title: string (creative recipe name)
        - description: string (brief appetizing description)
        - ingredients: array of strings (all ingredients with measurements)
        - instructions: array of strings (step-by-step cooking instructions)
        - cuisine: string (type of cuisine)
        - prep_time: string (preparation time like "15 minutes")
        - cook_time: string (cooking time like "30 minutes")
        - servings: number (how many people it serves)
        
        Make sure the recipe is practical and delicious using the provided ingredients."""

        # Initialize Gemini chat
        chat = LlmChat(
            api_key=GEMINI_API_KEY,
            session_id=f"recipe_gen_{uuid.uuid4()}",
            system_message="You are a professional chef and recipe creator. You create amazing recipes from given ingredients."
        ).with_model("gemini", "gemini-2.0-flash")

        # Send message to Gemini
        user_message = UserMessage(text=prompt)
        response = await chat.send_message(user_message)
        
        # Parse response and create recipe
        import json
        try:
            # Extract JSON from response
            response_text = response.strip()
            if "```json" in response_text:
                start = response_text.find("```json") + 7
                end = response_text.find("```", start)
                response_text = response_text[start:end].strip()
            elif "```" in response_text:
                start = response_text.find("```") + 3
                end = response_text.find("```", start)
                response_text = response_text[start:end].strip()
            
            recipe_data = json.loads(response_text)
        except:
            # Fallback parsing if JSON is not properly formatted
            recipe_data = {
                "title": "Delicious Recipe",
                "description": "A wonderful dish made with your ingredients",
                "ingredients": request.ingredients,
                "instructions": ["Mix all ingredients", "Cook until done", "Serve hot"],
                "cuisine": request.cuisine or "International",
                "prep_time": "15 minutes",
                "cook_time": "30 minutes",
                "servings": 4
            }

        # Create recipe object
        recipe = Recipe(
            title=recipe_data.get("title", "Delicious Recipe"),
            description=recipe_data.get("description", "A wonderful dish"),
            ingredients=recipe_data.get("ingredients", request.ingredients),
            instructions=recipe_data.get("instructions", ["Cook until done"]),
            cuisine=recipe_data.get("cuisine", request.cuisine or "International"),
            diet_type=request.diet_type,
            prep_time=recipe_data.get("prep_time", "15 minutes"),
            cook_time=recipe_data.get("cook_time", "30 minutes"),
            servings=recipe_data.get("servings", 4)
        )

        # Save to database
        await db.recipes.insert_one(recipe.dict())
        
        return recipe

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to generate recipe: {str(e)}")

@api_router.post("/recipes/{recipe_id}/generate-image")
async def generate_recipe_image(recipe_id: str):
    try:
        # Find the recipe
        recipe_data = await db.recipes.find_one({"id": recipe_id})
        if not recipe_data:
            raise HTTPException(status_code=404, detail="Recipe not found")
        
        # Create prompt for image generation
        recipe_title = recipe_data.get("title", "Delicious dish")
        cuisine = recipe_data.get("cuisine", "")
        prompt = f"A beautifully plated {recipe_title}, {cuisine} cuisine, professional food photography, appetizing, vibrant colors, restaurant quality presentation"

        # Initialize Gemini image generator
        image_gen = GeminiImageGeneration(api_key=GEMINI_API_KEY)
        
        # Generate image
        images = await image_gen.generate_images(
            prompt=prompt,
            model="imagen-3.0-generate-002",
            number_of_images=1
        )

        # Convert image to base64
        if images and len(images) > 0:
            image_base64 = base64.b64encode(images[0]).decode('utf-8')
            
            # Update recipe with image
            await db.recipes.update_one(
                {"id": recipe_id},
                {"$set": {"image_base64": image_base64}}
            )
            
            # Save generated image
            generated_image = GeneratedImage(
                recipe_id=recipe_id,
                image_base64=image_base64
            )
            await db.generated_images.insert_one(generated_image.dict())
            
            return {"image_base64": image_base64}
        else:
            raise HTTPException(status_code=500, detail="No image was generated")

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to generate image: {str(e)}")

@api_router.get("/recipes", response_model=List[Recipe])
async def get_recipes(limit: int = 20):
    try:
        recipes = await db.recipes.find().sort("created_at", -1).limit(limit).to_list(limit)
        return [Recipe(**recipe) for recipe in recipes]
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch recipes: {str(e)}")

@api_router.get("/recipes/{recipe_id}", response_model=Recipe)
async def get_recipe(recipe_id: str):
    try:
        recipe_data = await db.recipes.find_one({"id": recipe_id})
        if not recipe_data:
            raise HTTPException(status_code=404, detail="Recipe not found")
        return Recipe(**recipe_data)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch recipe: {str(e)}")

@api_router.get("/surprise-me", response_model=Recipe)
async def surprise_me():
    try:
        # Get a random recipe from database
        pipeline = [{"$sample": {"size": 1}}]
        result = await db.recipes.aggregate(pipeline).to_list(1)
        
        if result:
            return Recipe(**result[0])
        else:
            # Generate a random recipe if no recipes in database
            sample_ingredients = ["chicken", "onions", "garlic", "tomatoes", "herbs"]
            request = RecipeRequest(
                ingredients=sample_ingredients,
                diet_type="healthy"
            )
            return await generate_recipe(request)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get surprise recipe: {str(e)}")

# Include the router in the main app
app.include_router(api_router)

app.add_middleware(
    CORSMiddleware,
    allow_credentials=True,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

@app.on_event("shutdown")
async def shutdown_db_client():
    client.close()
