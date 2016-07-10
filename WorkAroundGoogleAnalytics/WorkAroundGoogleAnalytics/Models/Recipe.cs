using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WorkAroundGoogleAnalytics.Models
{
    public class Response
    {
        public Recipe Recipe { get; set; }
    }
    public class Recipe
    {
        public string RecipeId { get; set; }
    }
}