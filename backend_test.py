import requests
import json
import time
import os
import sys
from dotenv import load_dotenv
import unittest

# Load environment variables from frontend/.env to get the backend URL
load_dotenv('/app/frontend/.env')

# Get the backend URL from environment variables
BACKEND_URL = os.environ.get('REACT_APP_BACKEND_URL')
if not BACKEND_URL:
    print("Error: REACT_APP_BACKEND_URL not found in environment variables")
    sys.exit(1)

# Ensure the URL ends with /api
API_URL = f"{BACKEND_URL}/api"
print(f"Using API URL: {API_URL}")

class CravynBackendTest(unittest.TestCase):
    """Test suite for Cravyn backend API endpoints"""
    
    def test_01_health_check(self):
        """Test the root endpoint to verify server is running"""
        response = requests.get(f"{API_URL}/")
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertIn("message", data)
        self.assertIn("Cravyn", data["message"])
        print("✅ Health check passed")
    
    def test_02_generate_recipe_basic(self):
        """Test recipe generation with basic ingredients"""
        payload = {
            "ingredients": ["chicken", "rice", "onions"]
        }
        response = requests.post(f"{API_URL}/recipes/generate", json=payload)
        self.assertEqual(response.status_code, 200)
        data = response.json()
        
        # Verify response structure
        self.assertIn("id", data)
        self.assertIn("title", data)
        self.assertIn("description", data)
        self.assertIn("ingredients", data)
        self.assertIn("instructions", data)
        
        # Store recipe ID for later tests
        self.recipe_id = data["id"]
        print(f"✅ Basic recipe generation passed - Created recipe: {data['title']}")
        return data
    
    def test_03_generate_recipe_with_diet(self):
        """Test recipe generation with dietary preferences"""
        payload = {
            "ingredients": ["tofu", "broccoli", "carrots"],
            "diet_type": "vegetarian"
        }
        response = requests.post(f"{API_URL}/recipes/generate", json=payload)
        self.assertEqual(response.status_code, 200)
        data = response.json()
        
        # Verify response structure and diet type
        self.assertIn("diet_type", data)
        self.assertEqual(data["diet_type"], "vegetarian")
        print(f"✅ Recipe generation with dietary preference passed - Created recipe: {data['title']}")
        return data
    
    def test_04_generate_recipe_with_cuisine(self):
        """Test recipe generation with cuisine preferences"""
        payload = {
            "ingredients": ["pasta", "tomatoes", "basil"],
            "cuisine": "Italian"
        }
        response = requests.post(f"{API_URL}/recipes/generate", json=payload)
        self.assertEqual(response.status_code, 200)
        data = response.json()
        
        # Verify response structure and cuisine
        self.assertIn("cuisine", data)
        self.assertEqual(data["cuisine"], "Italian")
        print(f"✅ Recipe generation with cuisine preference passed - Created recipe: {data['title']}")
        return data
    
    def test_05_get_all_recipes(self):
        """Test retrieving all recipes"""
        response = requests.get(f"{API_URL}/recipes")
        self.assertEqual(response.status_code, 200)
        data = response.json()
        
        # Verify we get a list of recipes
        self.assertIsInstance(data, list)
        if len(data) > 0:
            self.assertIn("id", data[0])
            self.assertIn("title", data[0])
        
        print(f"✅ Get all recipes passed - Retrieved {len(data)} recipes")
        return data
    
    def test_06_get_recipe_by_id(self):
        """Test retrieving a specific recipe by ID"""
        # First, generate a recipe if we don't have one
        if not hasattr(self, 'recipe_id'):
            recipe = self.test_02_generate_recipe_basic()
            self.recipe_id = recipe["id"]
        
        response = requests.get(f"{API_URL}/recipes/{self.recipe_id}")
        self.assertEqual(response.status_code, 200)
        data = response.json()
        
        # Verify response structure
        self.assertEqual(data["id"], self.recipe_id)
        self.assertIn("title", data)
        self.assertIn("ingredients", data)
        
        print(f"✅ Get recipe by ID passed - Retrieved recipe: {data['title']}")
        return data
    
    def test_07_generate_image(self):
        """Test generating an image for a recipe"""
        # First, generate a recipe if we don't have one
        if not hasattr(self, 'recipe_id'):
            recipe = self.test_02_generate_recipe_basic()
            self.recipe_id = recipe["id"]
        
        response = requests.post(f"{API_URL}/recipes/{self.recipe_id}/generate-image")
        self.assertEqual(response.status_code, 200)
        data = response.json()
        
        # Verify image data is returned
        self.assertIn("image_base64", data)
        self.assertTrue(len(data["image_base64"]) > 0)
        
        print(f"✅ Image generation passed - Generated image for recipe ID: {self.recipe_id}")
        return data
    
    def test_08_surprise_me(self):
        """Test the surprise me feature for random recipe suggestions"""
        response = requests.get(f"{API_URL}/surprise-me")
        self.assertEqual(response.status_code, 200)
        data = response.json()
        
        # Verify response structure
        self.assertIn("id", data)
        self.assertIn("title", data)
        self.assertIn("ingredients", data)
        self.assertIn("instructions", data)
        
        print(f"✅ Surprise me feature passed - Got random recipe: {data['title']}")
        return data
    
    def test_09_database_persistence(self):
        """Test that recipes are properly stored in the database"""
        # First, generate a recipe
        recipe = self.test_02_generate_recipe_basic()
        recipe_id = recipe["id"]
        
        # Then retrieve it to verify it was stored
        response = requests.get(f"{API_URL}/recipes/{recipe_id}")
        self.assertEqual(response.status_code, 200)
        retrieved_recipe = response.json()
        
        # Verify the retrieved recipe matches the generated one
        self.assertEqual(retrieved_recipe["id"], recipe_id)
        self.assertEqual(retrieved_recipe["title"], recipe["title"])
        
        print(f"✅ Database persistence test passed - Recipe was properly stored and retrieved")

if __name__ == "__main__":
    # Run the tests in order
    test_suite = unittest.TestSuite()
    test_suite.addTest(CravynBackendTest('test_01_health_check'))
    test_suite.addTest(CravynBackendTest('test_02_generate_recipe_basic'))
    test_suite.addTest(CravynBackendTest('test_03_generate_recipe_with_diet'))
    test_suite.addTest(CravynBackendTest('test_04_generate_recipe_with_cuisine'))
    test_suite.addTest(CravynBackendTest('test_05_get_all_recipes'))
    test_suite.addTest(CravynBackendTest('test_06_get_recipe_by_id'))
    test_suite.addTest(CravynBackendTest('test_07_generate_image'))
    test_suite.addTest(CravynBackendTest('test_08_surprise_me'))
    test_suite.addTest(CravynBackendTest('test_09_database_persistence'))
    
    runner = unittest.TextTestRunner(verbosity=2)
    runner.run(test_suite)
