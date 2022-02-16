# frozen_string_literal: true

module Script
  module Forms
    class Create < ShopifyCLI::Form
      flag_arguments :extension_point, :title, :language

      def ask
        self.title = valid_name
        self.extension_point ||= ask_extension_point
        self.language = ask_language
      end

      private

      def ask_extension_point
        CLI::UI::Prompt.ask(
          @ctx.message("script.forms.create.select_extension_point"),
          options: Layers::Application::ExtensionPoints.available_types
        )
      end

      def ask_title
        CLI::UI::Prompt.ask(@ctx.message("script.forms.create.script_title"))
      end

      def valid_name
        t = (title || ask_title).downcase.gsub(" ", "_")
        return t if t.match?(/^[0-9A-Za-z_-]*$/)
        raise Errors::InvalidScriptTitleError
      end

      def ask_language
        return language.downcase if language

        all_languages = Layers::Application::ExtensionPoints.languages(type: extension_point)
        return all_languages.first if all_languages.count == 1

        CLI::UI::Prompt.ask(
          ctx.message("script.forms.create.select_language"),
          options: all_languages
        )
      end
    end
  end
end
