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
const CUISINES = ["Any", "Italian", "Mexican", "Asian", "Indian", "Mediterranean", "American", "French", "Thai", "Japanese"];

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
      fetchRecentRecipes(); // Refresh recent recipes
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
        setCurrentRecipe({
          ...currentRecipe,
          image_base64: response.data.image_base64
        });
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
      const response = await axios.get(`${API}/surprise-me`);
      setCurrentRecipe(response.data);
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
      {/* Header */}
      <header className="bg-white shadow-lg border-b-4 border-pink-500">
        <div className="max-w-7xl mx-auto px-4 py-6">
          <h1 className="text-4xl font-bold text-gray-800 text-center">
            🍳 <span className="text-pink-600">Cravyn</span>
          </h1>
          <p className="text-gray-600 text-center mt-2 text-lg">
            Cook What You Crave
          </p>
        </div>
      </header>

      <div className="max-w-7xl mx-auto px-4 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          
          {/* Left Column - Input Section */}
          <div className="space-y-6">
            {/* Hero Image */}
            <div className="rounded-2xl overflow-hidden shadow-xl">
              <img 
                src="https://images.unsplash.com/photo-1579113800032-c38bd7635818" 
                alt="Fresh ingredients"
                className="w-full h-64 object-cover"
              />
            </div>

            {/* Ingredient Input */}
            <div className="bg-white rounded-xl shadow-lg p-6">
              <h2 className="text-2xl font-semibold text-gray-800 mb-4">
                🥕 Add Your Ingredients
              </h2>
              
              <div className="relative mb-4">
                <input
                  type="text"
                  placeholder="Type or search for ingredients..."
                  value={customIngredient}
                  onChange={(e) => {
                    setCustomIngredient(e.target.value);
                    setShowIngredientDropdown(true);
                  }}
                  onFocus={() => setShowIngredientDropdown(true)}
                  className="w-full p-3 border-2 border-gray-300 rounded-lg focus:border-pink-500 focus:outline-none"
                />
                
                {showIngredientDropdown && customIngredient && (
                  <div className="absolute z-10 w-full bg-white border border-gray-300 rounded-lg mt-1 max-h-40 overflow-y-auto shadow-lg">
                    {filteredIngredients.slice(0, 6).map((ingredient, index) => (
                      <button
                        key={index}
                        onClick={() => addIngredient(ingredient)}
                        className="w-full text-left px-4 py-2 hover:bg-pink-50 border-b border-gray-100 last:border-b-0"
                      >
                        {ingredient}
                      </button>
                    ))}
                    {customIngredient && !COMMON_INGREDIENTS.includes(customIngredient.toLowerCase()) && (
                      <button
                        onClick={() => addIngredient(customIngredient)}
                        className="w-full text-left px-4 py-2 hover:bg-pink-50 font-medium text-pink-600"
                      >
                        Add "{customIngredient}"
                      </button>
                    )}
                  </div>
                )}
              </div>

              {/* Quick Add Buttons */}
              <div className="mb-4">
                <p className="text-sm text-gray-600 mb-2">Quick add popular ingredients:</p>
                <div className="flex flex-wrap gap-2">
                  {COMMON_INGREDIENTS.slice(0, 8).map((ingredient, index) => (
                    <button
                      key={index}
                      onClick={() => addIngredient(ingredient)}
                      disabled={selectedIngredients.includes(ingredient)}
                      className={`px-3 py-1 rounded-full text-sm transition-colors ${
                        selectedIngredients.includes(ingredient)
                          ? 'bg-gray-200 text-gray-500 cursor-not-allowed'
                          : 'bg-pink-100 text-pink-700 hover:bg-pink-200'
                      }`}
                    >
                      {ingredient}
                    </button>
                  ))}
                </div>
              </div>

              {/* Selected Ingredients */}
              {selectedIngredients.length > 0 && (
                <div className="mb-4">
                  <p className="text-sm text-gray-600 mb-2">Selected ingredients:</p>
                  <div className="flex flex-wrap gap-2">
                    {selectedIngredients.map((ingredient, index) => (
                      <span
                        key={index}
                        className="bg-orange-500 text-white px-3 py-1 rounded-full text-sm flex items-center gap-2"
                      >
                        {ingredient}
                        <button
                          onClick={() => removeIngredient(ingredient)}
                          className="text-orange-200 hover:text-white"
                        >
                          ×
                        </button>
                      </span>
                    ))}
                  </div>
                </div>
              )}
            </div>

            {/* Filters */}
            <div className="bg-white rounded-xl shadow-lg p-6">
              <h3 className="text-xl font-semibold text-gray-800 mb-4">🎯 Preferences</h3>
              
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">Diet Type</label>
                  <select
                    value={dietType}
                    onChange={(e) => setDietType(e.target.value)}
                    className="w-full p-3 border-2 border-gray-300 rounded-lg focus:border-orange-500 focus:outline-none"
                  >
                    {DIET_TYPES.map((diet, index) => (
                      <option key={index} value={diet}>{diet}</option>
                    ))}
                  </select>
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">Cuisine</label>
                  <select
                    value={cuisine}
                    onChange={(e) => setCuisine(e.target.value)}
                    className="w-full p-3 border-2 border-gray-300 rounded-lg focus:border-orange-500 focus:outline-none"
                  >
                    {CUISINES.map((c, index) => (
                      <option key={index} value={c}>{c}</option>
                    ))}
                  </select>
                </div>
              </div>
            </div>

            {/* Action Buttons */}
            <div className="flex gap-4">
              <button
                onClick={generateRecipe}
                disabled={isGenerating || selectedIngredients.length === 0}
                className="flex-1 bg-orange-600 text-white py-4 rounded-xl font-semibold text-lg hover:bg-orange-700 disabled:bg-gray-400 disabled:cursor-not-allowed transition-colors shadow-lg"
              >
                {isGenerating ? "🤖 Generating..." : "🍽️ Generate Recipe"}
              </button>
              
              <button
                onClick={surpriseMe}
                disabled={isGenerating}
                className="bg-purple-600 text-white px-6 py-4 rounded-xl font-semibold hover:bg-purple-700 disabled:bg-gray-400 transition-colors shadow-lg"
              >
                🎲 Surprise Me!
              </button>
            </div>
          </div>

          {/* Right Column - Recipe Display */}
          <div className="space-y-6">
            {currentRecipe ? (
              <div className="bg-white rounded-xl shadow-lg p-6">
                <div className="flex justify-between items-start mb-4">
                  <h2 className="text-2xl font-bold text-gray-800">{currentRecipe.title}</h2>
                  {!currentRecipe.image_base64 && (
                    <button
                      onClick={generateRecipeImage}
                      disabled={isGeneratingImage}
                      className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 disabled:bg-gray-400 transition-colors text-sm"
                    >
                      {isGeneratingImage ? "🎨 Generating..." : "📸 Generate Image"}
                    </button>
                  )}
                </div>

                {currentRecipe.image_base64 && (
                  <div className="mb-6">
                    <img 
                      src={`data:image/png;base64,${currentRecipe.image_base64}`}
                      alt={currentRecipe.title}
                      className="w-full h-64 object-cover rounded-lg shadow-md"
                    />
                  </div>
                )}

                <p className="text-gray-600 mb-4">{currentRecipe.description}</p>
                
                <div className="grid grid-cols-2 sm:grid-cols-4 gap-4 mb-6">
                  <div className="text-center p-2 bg-orange-50 rounded-lg">
                    <p className="text-xs text-gray-600">Prep Time</p>
                    <p className="font-semibold">{currentRecipe.prep_time}</p>
                  </div>
                  <div className="text-center p-2 bg-orange-50 rounded-lg">
                    <p className="text-xs text-gray-600">Cook Time</p>
                    <p className="font-semibold">{currentRecipe.cook_time}</p>
                  </div>
                  <div className="text-center p-2 bg-orange-50 rounded-lg">
                    <p className="text-xs text-gray-600">Servings</p>
                    <p className="font-semibold">{currentRecipe.servings}</p>
                  </div>
                  <div className="text-center p-2 bg-orange-50 rounded-lg">
                    <p className="text-xs text-gray-600">Cuisine</p>
                    <p className="font-semibold">{currentRecipe.cuisine}</p>
                  </div>
                </div>

                <div className="mb-6">
                  <h3 className="text-xl font-semibold mb-3">🛒 Ingredients</h3>
                  <ul className="space-y-2">
                    {currentRecipe.ingredients.map((ingredient, index) => (
                      <li key={index} className="flex items-center gap-2">
                        <span className="text-orange-500">•</span>
                        {ingredient}
                      </li>
                    ))}
                  </ul>
                </div>

                <div>
                  <h3 className="text-xl font-semibold mb-3">👨‍🍳 Instructions</h3>
                  <ol className="space-y-3">
                    {currentRecipe.instructions.map((instruction, index) => (
                      <li key={index} className="flex gap-3">
                        <span className="bg-orange-500 text-white rounded-full w-6 h-6 flex items-center justify-center text-sm font-semibold flex-shrink-0 mt-0.5">
                          {index + 1}
                        </span>
                        <span>{instruction}</span>
                      </li>
                    ))}
                  </ol>
                </div>
              </div>
            ) : (
              <div className="bg-white rounded-xl shadow-lg p-8 text-center">
                <div className="text-6xl mb-4">🍽️</div>
                <h2 className="text-2xl font-semibold text-gray-800 mb-2">Ready to Cook?</h2>
                <p className="text-gray-600">
                  Add your ingredients and let our AI create amazing recipes for you!
                </p>
              </div>
            )}

            {/* Recent Recipes */}
            {recentRecipes.length > 0 && (
              <div className="bg-white rounded-xl shadow-lg p-6">
                <h3 className="text-xl font-semibold text-gray-800 mb-4">📚 Recent Recipes</h3>
                <div className="space-y-3">
                  {recentRecipes.slice(0, 5).map((recipe, index) => (
                    <button
                      key={index}
                      onClick={() => setCurrentRecipe(recipe)}
                      className="w-full text-left p-3 bg-gray-50 rounded-lg hover:bg-orange-50 transition-colors border border-gray-200"
                    >
                      <h4 className="font-medium text-gray-800">{recipe.title}</h4>
                      <p className="text-sm text-gray-600">{recipe.cuisine} • {recipe.prep_time}</p>
                    </button>
                  ))}
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

export default App;