using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WorkAroundGoogleAnalytics.Models;

namespace WorkAroundGoogleAnalytics.Controllers
{
    public class HomeController : Controller
    {
        // GET: Home
        public ActionResult Index()
        {
            Response res = new Response();
            res.Recipe = new Recipe();
            res.Recipe.RecipeId = "222";
            return View(res);
        }
    }
}