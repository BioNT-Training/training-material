# frozen_string_literal: true

require 'json'
require 'fileutils'
require './_plugins/notebook'

module Jekyll
  module Generators
    # Generate RMarkdown documents from GTN markdown
    class RmarkdownGenerator < Generator
      safe true

      def generate(site)
        # For every tutorial with the 'notebook' key in the page data
        site.pages.select { |page| Gtn::Notebooks.notebook_filter(page.data, 'r') }.each do |page|
          # We get the path to the tutorial source
          dir = File.dirname(File.join('.', page.url))
          fn = File.join('.', page.url).sub(/html$/, 'Rmd')

          # Tag our source page
          page.data['tags'] = page.data['tags'] || []
          page.data['tags'].push('rmarkdown-notebook')

          Jekyll.logger.info "[GTN/Notebooks/R] Rendering RMarkdown #{fn}"
          last_modified = Gtn::ModificationTimes.obtain_time(page.path)
          notebook = Gtn::Notebooks.render_rmarkdown(site, page.data, page.content, page.url, last_modified, fn)

          topic_id = dir.split('/')[-3]
          tutorial_id = dir.split('/')[-1]

          # Write it out!
          page2 = PageWithoutAFile.new(site, '', dir, "#{topic_id}-#{tutorial_id}.Rmd")
          page2.content = notebook
          page2.data['layout'] = nil
          page2.data['citation_target'] = 'R'
          site.pages << page2
        end

        page3 = PageWithoutAFile.new(site, '', File.join('assets', 'css'), 'r-notebook.css')
        page3.content = Gtn::Notebooks.generate_css
        page3.data['layout'] = nil
        site.pages << page3
      end
    end
  end
end
