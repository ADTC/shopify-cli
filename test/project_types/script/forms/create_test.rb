# frozen_string_literal: true

require "project_types/script/test_helper"

module Script
  module Forms
    class CreateTest < MiniTest::Test
      include TestHelpers::Partners

      def setup
        super
        ShopifyCLI::ProjectType.load_type(:script)
        @context = TestHelpers::FakeContext.new
      end

      def test_returns_all_defined_attributes_if_valid
        title = "title"
        extension_point = "discount"
        form = ask(title: title, extension_point: extension_point, language: "assemblyscript")
        assert_equal(form.title, title)
        assert_equal(form.extension_point, extension_point)
      end

      def test_asks_extension_point_if_no_flag
        eps = ["discount", "another"]
        Layers::Application::ExtensionPoints.expects(:available_types).returns(eps)
        CLI::UI::Prompt.expects(:ask).with(
          @context.message("script.forms.create.select_extension_point"),
          options: eps
        )
        ask(title: "title", language: "assemblyscript")
      end

      def test_asks_title_if_no_flag
        title = "title"
        CLI::UI::Prompt.expects(:ask).with(@context.message("script.forms.create.script_title")).returns(title)
        form = ask(extension_point: "discount", language: "assemblyscript")
        assert_equal title, form.title
      end

      def test_title_is_cleaned_after_prompt
        title = "title with space"
        CLI::UI::Prompt.expects(:ask).with(@context.message("script.forms.create.script_title")).returns(title)
        form = ask(extension_point: "discount", language: "assemblyscript")
        assert_equal "title_with_space", form.title
      end

      def test_title_is_cleaned_when_using_flag
        form = ask(title: "title with space", extension_point: "discount", language: "assemblyscript")
        assert_equal "title_with_space", form.title
      end

      def test_invalid_title
        title = "na/me"
        CLI::UI::Prompt.expects(:ask).returns(title)

        assert_raises(Script::Errors::InvalidScriptTitleError) { ask }
      end

      def test_invalid_title_as_option
        assert_raises(Script::Errors::InvalidScriptTitleError) do
          ask(title: "na/me", language: "assemblyscript")
        end
      end

      def test_auto_selects_existing_language_if_only_one_exists
        language = "assemblyscript"
        Layers::Application::ExtensionPoints.expects(:languages).returns(%w(assemblyscript))
        CLI::UI::Prompt.expects(:ask).never
        form = ask(title: "title", extension_point: "discount")
        assert_equal language, form.language
      end

      def test_prompts_for_language_when_multiple_options_exist_and_no_flag_passed
        language = "rust"
        all_languages = %w(assemblyscript rust)
        Layers::Application::ExtensionPoints.expects(:languages).returns(all_languages)
        CLI::UI::Prompt
          .expects(:ask)
          .with(@context.message("script.forms.create.select_language"), options: all_languages)
          .returns(language)
        form = ask(title: "title", extension_point: "discount")
        assert_equal language, form.language
      end

      def test_succeeds_when_requested_language_is_capitalized
        language = "AssemblyScript"
        form = ask(title: "title", extension_point: "discount", language: language)
        assert_equal language.downcase, form.language
      end

      private

      def ask(title: nil, extension_point: nil, language: nil)
        Create.ask(
          @context,
          [],
          title: title,
          extension_point: extension_point,
          language: language
        )
      end
    end
  end
end
