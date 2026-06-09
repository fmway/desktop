{
  module_separator = " ";
  reset_color = true;

  bookmarks.search_depth = 20;

  module = [
    { type = "Symbol"; symbol = "on";
      color.TrueColor = rec { r = 200; g = r; b = r; };
    }
    { type = "Symbol"; symbol = "󱗆"; color = "Blue"; }
    { type = "Bookmarks";
      separator = " ";
      color = "Magenta";
      behind_symbol = "⇡";
      surround_with_quotes = false;
      ignore_empty_commits = "None";
    }
    { type = "Commit";
      previous_message_symbol = "⇣";
      max_length = 24;
      show_previous_if_empty = false;
      empty_text = "";
      surround_with_quotes = true;
      non_unique.color = "Black";
    }
    { type = "State";
      separator = " ";
      conflict.text = "💥";
      divergent.text = "🚧";
      immutable.text = "🔒";
      hidden.text = "👻";
      empty.text = "(empty)";
      empty.color = "Yellow";
    }
    { type = "Metrics";
      template = "[{changed} {added}{removed}]";
      hide_if_empty = true;
      changed_files = { prefix = ""; suffix = ""; color = "Cyan"; };
      added_lines   = { prefix = "+";suffix = ""; color = "Green"; };
      removed_lines = { prefix = "-";suffix = ""; color = "Red"; };
    }
  ];
}
