package cloudcode.helloworld.web;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * Defines a controller to handle HTTP requests.
 */
@Controller
public final class HelloWorldController {

  /**
   * Create an endpoint for the landing page.
   * @return the index view template
   */
  @GetMapping("/")
  public String helloWorld(Model model) {
    // Get the Project ID from the environment
    String projectId = System.getenv().getOrDefault("GOOGLE_CLOUD_PROJECT", "Unknown Project");
    
    // Add attributes to the model
    model.addAttribute("greeting", "Hello World!");
    model.addAttribute("project", projectId);
    model.addAttribute("status", "It's updated!");  // This text was updated from "It's running!"
    
    return "index";
  }
}
