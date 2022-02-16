# frozen_string_literal: true

module Script
  class Command
    class Create < ShopifyCLI::Command::SubCommand
      prerequisite_task :ensure_authenticated

      recommend_default_ruby_range

      options do |parser, flags|
        parser.on("--title=TITLE") { |title| flags[:title] = title }
        parser.on("--api=API_NAME") { |ep_name| flags[:extension_point] = ep_name }
        parser.on("--language=LANGUAGE") { |language| flags[:language] = language }
        parser.on("--branch=BRANCH") { |branch| flags[:branch] = branch }
      end

      def call(args, _name)
        form = Forms::Create.ask(@ctx, args, options.flags)
        return @ctx.puts(self.class.help) if form.nil?

        unless !form.title.empty? && form.extension_point && form.language
          return @ctx.puts(self.class.help)
        end

        project = Layers::Application::CreateScript.call(
          ctx: @ctx,
          language: form.language,
          sparse_checkout_branch: options.flags[:branch] || "master",
          title: form.title,
          extension_point_type: form.extension_point,
        )
        @ctx.puts(@ctx.message("script.create.change_directory_notice", project.title))
      rescue StandardError => e
        UI::ErrorHandler.pretty_print_and_raise(e, failed_op: @ctx.message("script.create.error.operation_failed"))
      end

      def self.help
        allowed_apis = Layers::Application::ExtensionPoints.available_types.map { |type| "{{cyan:#{type}}}" }
        allowed_languages = Layers::Application::ExtensionPoints.all_languages.map { |lang| "{{cyan:#{lang}}}" }
        ShopifyCLI::Context.message(
          "script.create.help",
          ShopifyCLI::TOOL_NAME,
          allowed_apis.join(", "),
          allowed_languages.join(", ")
        )
      end
    end
  end
end
