import React, { useState, useEffect } from "react";
import "./App.css";
import axios from "axios";

const BACKEND_URL = process.env.REACT_APP_BACKEND_URL;
const API = `${BACKEND_URL}/api`;

// Predefined ingredient options
const COMMON_INGREDIENTS = [
  "chicken", "beef", "pork", "fish", "shrimp", "eggs", "tofu",
  "rice", "pasta", "bread", "potatoes", "quinoa", "beans",
  "tomatoes", "onions", "garlic", "bell peppers", "carrots", "spinach",
  "mushrooms", "broccoli", "zucchini", "cucumber", "lettuce",
  "cheese", "milk", "butter", "yogurt", "cream",
  "olive oil", "salt", "pepper", "herbs", "spices", "lemon", "lime"
];
const DIET_TYPES = ["Any", "Vegetarian", "Vegan", "Keto", "Gluten-Free", "Paleo", "Low-Carb"];
const CUISINES = [
  "Any", "Italian", "Mexican", "Asian", "Indian", "Mediterranean", "American", "French", "Thai", "Japanese",
  // African Cuisines
  "Ethiopian", "Moroccan", "Nigerian", "South African", "Kenyan", "Ghanaian", "Egyptian", "Tunisian", 
  "Senegalese", "Congolese", "Sudanese", "Tanzanian", "Ugandan", "Rwandan", "Ivorian", "Malian", 
  "Cameroonian", "Zimbabwean", "Zambian", "Botswanan", "Namibian", "Algerian", "Libyan", "Somalian", 
  "Eritrean", "Central African", "Gabonese", "Chad", "Niger", "Burkina Faso", "Benin", "Togo", 
  "Sierra Leone", "Guinea", "Liberian", "Cape Verdean", "Mauritanian", "Gambian", "Burundian", 
  "Comorian", "Seychellois", "Mauritian", "Malagasy", "Lesotho", "Eswatini"
];

function App() {
  const [selectedIngredients, setSelectedIngredients] = useState([]);
  const [customIngredient, setCustomIngredient] = useState("");
  const [dietType, setDietType] = useState("Any");
  const [cuisine, setCuisine] = useState("Any");
  const [currentRecipe, setCurrentRecipe] = useState(null);
  const [recentRecipes, setRecentRecipes] = useState([]);
  const [isGenerating, setIsGenerating] = useState(false);
  const [isGeneratingImage, setIsGeneratingImage] = useState(false);
  const [showIngredientDropdown, setShowIngredientDropdown] = useState(false);
  const [historicalIngredients, setHistoricalIngredients] = useState([]);

  useEffect(() => {
    fetchRecentRecipes();
  }, []);
  const fetchRecentRecipes = async () => {
    try {
      const response = await axios.get(`${API}/recipes?limit=10`);
      setRecentRecipes(response.data);
    } catch (e) {
      console.error("Failed to fetch recent recipes", e);
    }
  };

  const addIngredient = (ingredient) => {
    if (ingredient && !selectedIngredients.includes(ingredient)) {
      setSelectedIngredients([...selectedIngredients, ingredient]);
      // Add to historical ingredients if not already present
      if (!historicalIngredients.includes(ingredient) && !COMMON_INGREDIENTS.includes(ingredient)) {
        setHistoricalIngredients(prev => {
          const updated = [ingredient, ...prev.filter(item => item !== ingredient)];
          return updated.slice(0, 10);
        });
      }
    }
    setCustomIngredient("");
    setShowIngredientDropdown(false);
  };

  const removeIngredient = (ingredient) => {
    setSelectedIngredients(selectedIngredients.filter(item => item !== ingredient));
  };

  const generateRecipe = async () => {
    if (selectedIngredients.length === 0) {
      alert("Please add at least one ingredient!");
      return;
    }
    setIsGenerating(true);
    try {
      const response = await axios.post(`${API}/recipes/generate`, {
        ingredients: selectedIngredients,
        diet_type: dietType !== "Any" ? dietType : null,
        cuisine: cuisine !== "Any" ? cuisine : null
      });
      setCurrentRecipe(response.data);
      fetchRecentRecipes();
    } catch (e) {
      console.error("Failed to generate recipe", e);
      alert("Failed to generate recipe. Please try again!");
    }
    setIsGenerating(false);
  };

  const generateRecipeImage = async () => {
    if (!currentRecipe) return;
    setIsGeneratingImage(true);
    try {
      const response = await axios.post(`${API}/recipes/${currentRecipe.id}/generate-image`);
      if (response.data.error_type === "billing_required") {
        alert(`Image generation requires Google Cloud billing account.\n\nTo enable image generation:\n1. Visit https://console.cloud.google.com/billing\n2. Set up billing for your Google Cloud project\n3. Ensure your API key has image generation permissions`);
      } else if (response.data.image_base64) {
        setCurrentRecipe({ ...currentRecipe, image_base64: response.data.image_base64 });
      }
    } catch (e) {
      console.error("Failed to generate image", e);
      if (e.response?.data?.detail?.includes("billed users")) {
        alert("Image generation requires a Google Cloud billing account. Please set up billing in Google Cloud Console to use this feature.");
      } else {
        alert("Failed to generate recipe image. Please try again!");
      }
    }
    setIsGeneratingImage(false);
  };

  const surpriseMe = async () => {
    setIsGenerating(true);
    try {
      if (dietType !== "Any" || cuisine !== "Any") {
        const randomIngredients = COMMON_INGREDIENTS.sort(() => Math.random() - 0.5)
          .slice(0, Math.floor(Math.random() * 4) + 3);
        const response = await axios.post(`${API}/recipes/generate`, {
          ingredients: randomIngredients,
          diet_type: dietType !== "Any" ? dietType : null,
          cuisine: cuisine !== "Any" ? cuisine : null
        });
        setCurrentRecipe(response.data);
      } else {
        const response = await axios.get(`${API}/surprise-me`);
        setCurrentRecipe(response.data);
      }
    } catch (e) {
      console.error("Failed to get surprise recipe", e);
      alert("Failed to get surprise recipe. Please try again!");
    }
    setIsGenerating(false);
  };

  const filteredIngredients = COMMON_INGREDIENTS.filter(ingredient =>
    ingredient.toLowerCase().includes(customIngredient.toLowerCase()) &&
    !selectedIngredients.includes(ingredient)
  );

  return (
    <div className="min-h-screen bg-gradient-to-br from-pink-50 via-peach-50 to-rose-50">
      {/* ...Header and container omitted for brevity... */}

      {/* Ingredient Dropdown - GUARDED */}
      {showIngredientDropdown && customIngredient && (
        <div className="absolute z-10 w-full bg-white border border-gray-300 rounded-lg mt-1 max-h-40 overflow-y-auto shadow-lg">
          {(Array.isArray(filteredIngredients) ? filteredIngredients : [])
            .slice(0, 6)
            .map((ingredient, index) => (
              <button key={index} onClick={() => addIngredient(ingredient)}
                className="w-full text-left px-4 py-2 hover:bg-pink-50 border-b border-gray-100 last:border-b-0">
                {ingredient}
              </button>
          ))}
          {customIngredient && !COMMON_INGREDIENTS.includes(customIngredient.toLowerCase()) && (
            <button onClick={() => addIngredient(customIngredient)}
              className="w-full text-left px-4 py-2 hover:bg-pink-50 font-medium text-pink-600">
              Add "{customIngredient}"
            </button>
          )}
        </div>
      )}

      {/* Quick Add Buttons - GUARDED */}
      <div className="flex flex-wrap gap-2">
        {(Array.isArray(historicalIngredients) && Array.isArray(COMMON_INGREDIENTS) ?
          [...historicalIngredients, ...COMMON_INGREDIENTS] : [])
          .filter((ingredient, index, arr) => arr.indexOf(ingredient) === index)
          .slice(0, 10)
          .map((ingredient, index) => (
            <button key={index} onClick={() => addIngredient(ingredient)}
                disabled={selectedIngredients.includes(ingredient)}
                className={`px-3 py-1 rounded-full text-sm transition-colors ${
                  selectedIngredients.includes(ingredient)
                    ? 'bg-gray-200 text-gray-500 cursor-not-allowed'
                    : historicalIngredients.includes(ingredient)
                      ? 'bg-purple-100 text-purple-700 hover:bg-purple-200 border border-purple-300'
                      : 'bg-pink-100 text-pink-700 hover:bg-pink-200'
                }`}>
                {historicalIngredients.includes(ingredient) ? `✨ ${ingredient}` : ingredient}
            </button>
        ))}
      </div>

      {/* Selected Ingredients - GUARDED */}
      {Array.isArray(selectedIngredients) && selectedIngredients.length > 0 && (
        <div className="mb-4">
          <p className="text-sm text-gray-600 mb-2">Selected ingredients:</p>
          <div className="flex flex-wrap gap-2">
            {(Array.isArray(selectedIngredients) ? selectedIngredients : []).map((ingredient, index) => (
              <span key={index} className="bg-pink-500 text-white px-3 py-1 rounded-full text-sm flex items-center gap-2">
                {ingredient}
                <button onClick={() => removeIngredient(ingredient)}
                  className="text-pink-200 hover:text-white">×</button>
              </span>
            ))}
          </div>
        </div>
      )}

      {/* Recipe Ingredients - GUARDED */}
      <ul className="space-y-2">
        {currentRecipe && Array.isArray(currentRecipe.ingredients) &&
          currentRecipe.ingredients.map((ingredient, index) => (
            <li key={index} className="flex items-center gap-2">
              <span className="text-pink-500">•</span>
              {ingredient}
            </li>
        ))}
      </ul>

      {/* Recipe Instructions - GUARDED */}
      <ol className="space-y-3">
        {currentRecipe && Array.isArray(currentRecipe.instructions) &&
          currentRecipe.instructions.map((instruction, index) => (
            <li key={index} className="flex gap-3">
              <span className="bg-pink-500 text-white rounded-full w-6 h-6 flex items-center justify-center text-sm font-semibold flex-shrink-0 mt-0.5">
                {index + 1}
              </span>
              <span>{instruction}</span>
            </li>
        ))}
      </ol>

      {/* Recent Recipes - GUARDED */}
      {Array.isArray(recentRecipes) && recentRecipes.length > 0 && (
        <div className="space-y-3">
          {(Array.isArray(recentRecipes) ? recentRecipes : [])
            .slice(0, 5)
            .map((recipe, index) => (
              <button key={index} onClick={() => setCurrentRecipe(recipe)}
                className="w-full text-left p-3 bg-gray-50 rounded-lg hover:bg-pink-50 transition-colors border border-gray-200">
                <h4 className="font-medium text-gray-800">{recipe.title}</h4>
                <p className="text-sm text-gray-600">{recipe.cuisine} • {recipe.prep_time}</p>
              </button>
          ))}
        </div>
      )}

      {/* ...Other app content as per your full code... */}
    </div>
  );
}

export default App;
