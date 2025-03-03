# frozen_string_literal: true

require 'json'
require 'yaml'
require './_plugins/gtn'
require './_plugins/util'
require 'securerandom'

class Array
  def cumulative_sum
    sum = 0
    self.map{|x| sum += x}
  end
end

module Gtn
  # The main GTN module to parse tutorial.md and slides.html and topics into useful lists of things that can be shown on topic pages, i.e. "materials" (a possible combination of tutorial + slides)
  #
  # This is by far the most complicated module and the least
  # disaggregated/modular part of the GTN infrastructure.
  # TopicFilter.resolve_material is probably the single most important function
  # in the entire suite.
  module TopicFilter


    ##
    # This function returns a list of all the topics that are available.
    # Params:
    # +site+:: The +Jekyll::Site+ object
    # Returns:
    # +Array+:: The list of topics
    def self.list_topics(site)
      list_topics_h(site).keys
    end

    def self.list_topics_h(site)
      site.data.select { |_k, v| v.is_a?(Hash) && v.key?('editorial_board') }
    end

    ##
    # This function returns a list of all the topics that are available.
    # Params:
    # +site+:: The +Jekyll::Site+ object
    # Returns:
    # +Array+:: The topic objects themselves
    def self.enumerate_topics(site)
      list_topics_h(site).values
    end

    ##
    # Setup the local cache via +Jekyll::Cache+
    def self.cache
      @@cache ||= Jekyll::Cache.new('GtnTopicFilter')
    end

    ##
    # Fill the cache with all the topics if it hasn't been done already. Safe to be called multiple times.
    # Params:
    # +site+:: The +Jekyll::Site+ object
    # Returns:
    # +nil+
    def self.fill_cache(site)
      return if site.data.key?('cache_topic_filter')

      Jekyll.logger.debug '[GTN/TopicFilter] Begin Cache Prefill'
      site.data['cache_topic_filter'] = {}

      # For each topic
      list_topics(site).each do |topic|
        site.data['cache_topic_filter'][topic] = filter_by_topic(site, topic)
      end
      Jekyll.logger.debug '[GTN/TopicFilter] End Cache Prefill'
    end

    ##
    # This function returns a list of all the materials that are available for a specific topic.
    # Params:
    # +site+:: The +Jekyll::Site+ object
    # +topic_name+:: The name of the topic
    # Returns:
    # +Array+:: The list of materials
    def self.topic_filter(site, topic_name)
      fill_cache(site)
      site.data['cache_topic_filter'][topic_name]
    end

    ##
    # This function returns a list of all the materials that are available for a
    # specific topic, but this time in a structured manner
    # Params:
    # +site+:: The +Jekyll::Site+ object
    # +topic_name+:: The name of the topic
    # Returns:
    # +Hash+:: The subtopics and their materials
    #
    # Example:
    #  {
    #   "intro" => {
    #     "subtopic" => {"title" => "Introduction", "description" => "Introduction to the topic", "id" => "intro"},
    #     "materials" => [
    #       ...
    #     ]
    #   },
    #   "__OTHER__" => {
    #     "subtopic" => {"title" => "Other", "description" => "Other materials", "id" => "__OTHER__"},
    #     "materials" => [.. ]
    #   }
    #  ]
    # This method is built with the idea to replace the "topic_filter" command,
    # and instead of returning semi-structured data, we will immediately return
    # fully structured data for a specific "topic_name" query, like, "admin"
    #
    # Instead of returning a flat list of tutorials, instead we'll structure
    # them properly in subtopics (if they exist) or return the flat list
    # otherwise.
    #
    # This will let us generate new "views" into the tutorial lists, having
    # them arranged in new and exciting ways.
    def self.list_materials_structured(site, topic_name)

      fill_cache(site)

      # Here we want to either return data structured around subtopics

      if site.data[topic_name]['tag_based'].nil? && site.data[topic_name].key?('subtopics')
        # We'll construct a new hash of subtopic => tutorials
        out = {}
        seen_ids = []
        site.data[topic_name]['subtopics'].each do |subtopic, _v|
          specific_resources = filter_by_topic_subtopic(site, topic_name, subtopic['id'])
          out[subtopic['id']] = {
            'subtopic' => subtopic,
            'materials' => specific_resources
          }
          seen_ids += specific_resources.map { |x| x['id'] }
        end

        # And we'll have this __OTHER__ subtopic for any tutorials that weren't
        # in a subtopic.
        all_topics_for_tutorial = filter_by_topic(site, topic_name)
        out['__OTHER__'] = {
          'subtopic' => { 'title' => 'Other', 'description' => 'Assorted Tutorials', 'id' => 'other' },
          'materials' => all_topics_for_tutorial.reject { |x| seen_ids.include?(x['id']) }
        }
      elsif site.data[topic_name]['tag_based'] && site.data[topic_name].key?('subtopics')
        out = {}
        seen_ids = []
        tn = topic_name.gsub('by_tag_', '')
        materials = filter_by_tag(site, tn)

        # For each subtopics
        site.data[topic_name]['subtopics'].each do |subtopic|
          # Find matching tag-based tutorials in our filtered-by-tag materials
          specific_resources = materials.select { |x| (x['tags'] || []).include?(subtopic['id']) }
          out[subtopic['id']] = {
            'subtopic' => subtopic,
            'materials' => specific_resources
          }
          seen_ids += specific_resources.map { |x| x['id'] }
        end

        filter_by_tag(site, tn)
        out['__OTHER__'] = {
          'subtopic' => { 'title' => 'Other', 'description' => 'Assorted Tutorials', 'id' => 'other' },
          'materials' => materials.reject { |x| seen_ids.include?(x['id']) }
        }
      elsif site.data[topic_name]['tag_based'] # Tag based Topic
        # We'll construct a new hash of subtopic(parent topic) => tutorials
        out = {}
        seen_ids = []
        tn = topic_name.gsub('by_tag_', '')
        materials = filter_by_tag(site, tn)

        # Which topics are represented in those materials?
        seen_topics = materials.map { |x| x['topic_name'] }.sort

        # Treat them like subtopics, but fake subtopics.
        seen_topics.each do |parent_topic, _v|
          specific_resources = materials.select { |x| x['topic_name'] == parent_topic }
          out[parent_topic] = {
            'subtopic' => { 'id' => parent_topic, 'title' => site.data[parent_topic]['title'], 'description' => nil },
            'materials' => specific_resources
          }
          seen_ids += specific_resources.map { |x| x['id'] }
        end

        # And we'll have this __OTHER__ subtopic for any tutorials that weren't
        # in a subtopic.
        all_topics_for_tutorial = filter_by_tag(site, tn)
        out['__OTHER__'] = {
          'subtopic' => { 'title' => 'Other', 'description' => 'Assorted Tutorials', 'id' => 'other' },
          'materials' => all_topics_for_tutorial.reject { |x| seen_ids.include?(x['id']) }
        }
      else
        # Or just the list (Jury is still out on this one, should it really be a
        # flat list? Or in this identical structure.)
        out = {
          '__FLAT__' => {
            'subtopic' => nil,
            'materials' => filter_by_topic(site, topic_name)
          }
        }
      end

      # Cleanup empty sections
      out.delete('__OTHER__') if out.key?('__OTHER__') && out['__OTHER__']['materials'].empty?

      out.each do |_k, v|
        v['materials'].sort_by! { |m| [m.fetch('priority', 1), m['title']] }
      end

      out
    end

    ##
    # Fetch a specific tutorial material by topic and tutorial name
    # Params:
    # +site+:: The +Jekyll::Site+ object
    # +topic_name+:: The name of the topic
    # +tutorial_name+:: The name of the tutorial
    # Returns:
    # +Hash+:: The tutorial material
    def self.fetch_tutorial_material(site, topic_name, tutorial_name)
      if topic_name.nil?
        return nil
      end
      fill_cache(site)
      if site.data['cache_topic_filter'][topic_name].nil?
        Jekyll.logger.warn "Cannot fetch tutorial material for #{topic_name}"
        nil
      else
        site.data['cache_topic_filter'][topic_name].select { |p| p['tutorial_name'] == tutorial_name }[0]
      end
    end

    ##
    # Extract the list of tools used in a workflow
    # Params:
    # +data+:: The Galaxy Workflow JSON data, parsed
    # Returns:
    # +Array+:: The list of tool IDs
    def self.extract_workflow_tool_list(data)
      out = data['steps'].select { |_k, v| v['type'] == 'tool' }.map { |_k, v| v['tool_id'] }.compact
      out += data['steps'].select do |_k, v|
               v['type'] == 'subworkflow'
             end.map { |_k, v| extract_workflow_tool_list(v['subworkflow']) }
      out
    end

    ##
    # Annotation of a path with topic and tutorial information
    # Params:
    # +path+:: The path to annotate
    # +layout+:: The page layout if known
    # Returns:
    # +Hash+:: The annotation
    #
    # Example:
    #
    #   h = Gtn::TopicFilter.annotate_path("topics/assembly/tutorials/velvet-assembly/tutorial.md", nil)
    #   h # => {
    #     #  "topic"=>"assembly",
    #     #  "topic_name"=>"assembly",
    #     #  "material"=>"assembly/velvet-assembly",
    #     #  "tutorial_name"=>"velvet-assembly",
    #     #  "dir"=>"topics/assembly/tutorials/velvet-assembly",
    #     #  "type"=>"tutorial"
    #     # }

    def self.annotate_path(path, layout)
      parts = path.split('/')
      parts.shift if parts[0] == '.'

      return nil if parts[0] != 'topics'

      return nil if parts[2] != 'tutorials'

      return nil if parts.length < 4

      material = {
        'topic' => parts[1], # Duplicate
        'topic_name' => parts[1],
        'material' => "#{parts[1]}/#{parts[3]}",
        'tutorial_name' => parts[3],
        'dir' => parts[0..3].join('/'),
      }

      return nil if path =~ %r{/faqs/}

      return nil if parts[-1] =~ /data[_-]library.yaml/ || parts[-1] =~ /data[_-]manager.yaml/

      # Check if it's a symlink
      material['symlink'] = true if File.symlink?(material['dir'])

      if parts[4] =~ /tutorial.*\.md/ || layout == 'tutorial_hands_on'
        material['type'] = 'tutorial'
      elsif parts[4] =~ /slides.*\.html/ || %w[tutorial_slides base_slides introduction_slides].include?(layout)
        material['type'] = 'slides'
      elsif parts[4] =~ /ipynb$/
        material['type'] = 'ipynb'
      elsif parts[4] =~ /Rmd$/
        material['type'] = 'rmd'
      elsif parts[4] == 'workflows'
        material['type'] = 'workflow'
      elsif parts[4] == 'recordings'
        material['type'] = 'recordings'
      elsif parts[4] == 'tours'
        material['type'] = 'tour'
      elsif parts[-1] == 'index.md'
        return nil
      else
        return nil
        # material['type'] = 'unknown'
      end

      material
    end

    ##
    # Get the list of posts from the site
    # Params:
    # +site+:: The +Jekyll::Site+ object
    # Returns:
    # +Array+:: The list of posts
    #
    # This is a transition period function that can later be removed. It is added
    # because with the jekyll version we're using, site.posts is an iterable in
    # prod+dev (_config-dev.yml) modes, however! If we access site.posts.docs in
    # prod it's fine, while in dev mode, site.posts claims to be an Array (rather
    # than I guess a 'posts' object with a docs method). So we check if it has
    # docs and use that, otherwise just site.posts should be iterable.
    def self.get_posts(site)
      # Handle the transition period
      if site.posts.respond_to?(:docs)
        site.posts.docs
      else
        site.posts
      end
    end

    ##
    # Collate the materials into a large hash
    # Params:
    # +site+:: The +Jekyll::Site+ object
    # +pages+:: The list of pages to collate
    # Returns:
    # +Hash+:: The collated materials
    #
    # Example:
    #   h = collate_materials(site, pages)
    #   h # => {
    #     # "assembly/velvet-assembly" => {
    #     #  "topic" => "assembly",
    #     #  "topic_name" => "assembly",
    #     #  "material" => "assembly/velvet-assembly",
    #     #  "tutorial_name" => "velvet-assembly",
    #     #  "dir" => "topics/assembly/tutorials/velvet-assembly",
    #     #  "resources" => [
    #     #    {
    #     #    "type" => "slides",
    #     #    "url" => "/topics/assembly/tutorials/velvet-assembly/slides.html",
    #     #    "title" => "Slides",
    #     #    "priority" => 1
    #     #    },
    #     #    {
    #     #    "type" => "tutorial",
    #     #    "url" => "/topics/assembly/tutorials/velvet-assembly/tutorial.html",
    #     #    "title" => "Tutorial",
    #     #    "priority" => 2
    #     #    }
    #     #   ]
    #     #  }
    def self.collate_materials(site, pages)
      # In order to speed up queries later, we'll store a set of "interesting"
      # pages (i.e. things that are under `topic_name`)
      shortlinks = site.data['shortlinks']
      shortlinks_reversed = shortlinks['id'].invert

      interesting = {}
      pages.each do |page|
        # Skip anything outside of topics.
        next if !page.url.include?('/topics/')

        # Extract the material metadata based on the path
        page.data['url'] = page.url
        material_meta = annotate_path(page.path, page.data['layout'])

        # If unannotated then we want to skip this material.
        next if material_meta.nil?

        mk = material_meta['material']

        if !interesting.key? mk
          interesting[mk] = material_meta.dup
          interesting[mk].delete('type') # Remove the type since it's specific, not generic
          interesting[mk]['resources'] = []
        end

        page.data['topic_name'] = material_meta['topic_name']
        page.data['tutorial_name'] = material_meta['tutorial_name']
        page.data['dir'] = material_meta['dir']
        page.data['short_id'] = shortlinks_reversed[page.data['url']]
        page.data['symlink'] = material_meta['symlink']

        interesting[mk]['resources'].push([material_meta['type'], page])
      end

      interesting
    end

    ##
    # Make a label safe for use in mermaid (without ()[]"')
    def self.mermaid_safe_label(label)
      (label || '')
        .gsub('(', '').gsub(')', '')
        .gsub('[', '').gsub(']', '')
        .gsub('"', '”') # We accept that this is not perfectly correct.
        .gsub("'", '’')
    end

    ##
    # Build a Mermaid.js compatible graph of a given Galaxy Workflow
    #
    # TODO: extract into own module along with DOT>
    #
    # Params:
    # +wf+:: The Galaxy Workflow JSON representation
    # Returns:
    # +String+:: A Mermaid.js compatible graph of the workflow.
    def self.mermaid(wf)
      # We're converting it to Mermaid.js
      # flowchart TD
      #     A[Start] --> B{Is it?}
      #     B -- Yes --> C[OK]
      #     C --> D[Rethink]
      #     D --> B
      #     B -- No ----> E[End]

      statements = []
      wf['steps'].each_key do |id|
        step = wf['steps'][id]
        chosen_label = mermaid_safe_label(step['label'] || step['name'])

        case step['type']
        when 'data_collection_input'
          statements.append "#{id}[\"ℹ️ Input Collection\\n#{chosen_label}\"];"
        when 'data_input'
          statements.append "#{id}[\"ℹ️ Input Dataset\\n#{chosen_label}\"];"
        when 'parameter_input'
          statements.append "#{id}[\"ℹ️ Input Parameter\\n#{chosen_label}\"];"
        when 'subworkflow'
          statements.append "#{id}[\"🛠️ Subworkflow\\n#{chosen_label}\"];"
        else
          statements.append "#{id}[\"#{chosen_label}\"];"
        end

        case step['type']
        when 'data_collection_input', 'data_input'
          statements.append "style #{id} stroke:#2c3143,stroke-width:4px;"
        when 'parameter_input'
          statements.append "style #{id} fill:#ded,stroke:#393,stroke-width:4px;"
        when 'subworkflow'
          statements.append "style #{id} fill:#edd,stroke:#900,stroke-width:4px;"
        end

        step = wf['steps'][id]
        step['input_connections'].each do |_, v|
          # if v is a list
          if v.is_a?(Array)
            v.each do |v2|
              statements.append "#{v2['id']} -->|#{mermaid_safe_label(v2['output_name'])}| #{id};"
            end
          else
            statements.append "#{v['id']} -->|#{mermaid_safe_label(v['output_name'])}| #{id};"
          end
        end

        (step['workflow_outputs'] || [])
          .reject { |wo| wo['label'].nil? }
          .map do |wo|
            wo['uuid'] = SecureRandom.uuid.to_s if wo['uuid'].nil?
            wo
          end
          .each do |wo|
          statements.append "#{wo['uuid']}[\"Output\\n#{wo['label']}\"];"
          statements.append "#{id} --> #{wo['uuid']};"
          statements.append "style #{wo['uuid']} stroke:#2c3143,stroke-width:4px;"
        end
      end

      "flowchart TD\n" + statements.map { |q| "  #{q}" }.join("\n")
    end

    ##
    # Build a DOT graph for a given tutorial file.
    #
    # TODO: extract into own module along with mermaid.
    #
    # Params:
    # +wf+:: The Galaxy Workflow JSON representation
    # Returns:
    # +String+:: A DOT graph of the workflow.
    def self.graph_dot(wf)
      # digraph test {
      #   0[shape=box,style=filled,color=lightblue,label="ℹ️ Input Dataset\nBionano_dataset"]
      #   1[shape=box,style=filled,color=lightblue,label="ℹ️ Input Dataset\nHi-C_dataset_R"]
      #   3 -> 6 [label="output"]
      #   7[shape=box,label="Busco"]
      #   4 -> 7 [label="out_fa"]
      #   8[shape=box,label="Busco"]
      #   5 -> 8 [label="out_fa"]

      statements = [
        'node [fontname="Atkinson Hyperlegible", shape=box, color=white,style=filled,color=peachpuff,margin="0.2,0.2"];',
        'edge [fontname="Atkinson Hyperlegible"];',
      ]
      wf['steps'].each_key do |id|
        step = wf['steps'][id]
        chosen_label = mermaid_safe_label(step['label'] || step['name'])

        case step['type']
        when 'data_collection_input'
          statements.append "#{id}[color=lightblue,label=\"ℹ️ Input Collection\\n#{chosen_label}\"]"
        when 'data_input'
          statements.append "#{id}[color=lightblue,label=\"ℹ️ Input Dataset\\n#{chosen_label}\"]"
        when 'parameter_input'
          statements.append "#{id}[color=lightgreen,label=\"ℹ️ Input Parameter\\n#{chosen_label}\"]"
        when 'subworkflow'
          statements.append "#{id}[color=lightcoral,label=\"🛠️ Subworkflow\\n#{chosen_label}\"]"
        else
          statements.append "#{id}[label=\"#{chosen_label}\"]"
        end

        step = wf['steps'][id]
        step['input_connections'].each do |_, v|
          # if v is a list
          if v.is_a?(Array)
            v.each do |v2|
              statements.append "#{v2['id']} -> #{id} [label=\"#{mermaid_safe_label(v2['output_name'])}\"]"
            end
          else
            statements.append "#{v['id']} -> #{id} [label=\"#{mermaid_safe_label(v['output_name'])}\"]"
          end
        end

        (step['workflow_outputs'] || [])
          .reject { |wo| wo['label'].nil? }
          .map do |wo|
            wo['uuid'] = SecureRandom.uuid.to_s if wo['uuid'].nil?
            wo
          end
          .each do |wo|
            statements.append "k#{wo['uuid'].gsub('-', '')}[color=lightseagreen,label=\"Output\\n#{wo['label']}\"]"
            statements.append "#{id} -> k#{wo['uuid'].gsub('-', '')}"
          end
      end

      "digraph main {\n" + statements.map { |q| "  #{q}" }.join("\n") + "\n}"
    end

    ##
    # (PRODUCTION ONLY) Extract a log of commits (hash, timestamp, message) for commits to a specific path
    #
    # Params:
    # +wf_path+:: Path to a file
    # Returns:
    # +Array+:: An array of {'hash' => ..., 'unix' => 1230, 'message' => 'I did something', 'short_hash' => ... }
    def self.git_log(wf_path)
      if Jekyll.env != 'production'
        return []
      end

      cache.getset(wf_path) do
        require 'shellwords'

        commits = %x[git log --format="%H %at %s" #{Shellwords.escape(wf_path)}]
          .split("\n")
          .map { |x| x.split(' ', 3) }
          .map { |x| { 'hash' => x[0], 'unix' => x[1], 'message' => x[2], 'short_hash' => x[0][0..8] } }

        commits.map.with_index do |c, i|
          c['num'] = commits.length - i
          c
        end
      end
    end

    ##
    # Resolve a material from a given collated material. What does that entail? A LOT.
    #
    # Given a collated material, e.g.
    #
    #    material = Gtn::TopicFilter.collate_materials(site, site.pages)['proteomics/database-handling']
    #    material # =>
    #        # {"topic"=>"proteomics",
    #        #  "topic_name"=>"proteomics",
    #        #  "material"=>"proteomics/database-handling",
    #        #  "tutorial_name"=>"database-handling",
    #        #  "dir"=>"topics/proteomics/tutorials/database-handling",
    #        #  "resources"=>
    #        #   [["workflow", #<Jekyll::Page @relative_path="topics/proteomics/tutorials/database-handling/workflows/index.md">],
    #        #    ["tour", #<Jekyll::Page @relative_path="topics/proteomics/tutorials/database-handling/tours/proteomics-database-handling-mycroplasma.yaml">],
    #        #    ["tour", #<Jekyll::Page @relative_path="topics/proteomics/tutorials/database-handling/tours/proteomics-database-handling.yaml">],
    #        #    ["tutorial", #<Jekyll::Page @relative_path="topics/proteomics/tutorials/database-handling/tutorial.md">],
    #        #    ["recordings", #<Jekyll::PageWithoutAFile @relative_path="topics/proteomics/tutorials/database-handling/recordings/index.html">],
    #        #    ["workflow", #<Jekyll::PageWithoutAFile @relative_path="topics/proteomics/tutorials/database-handling/workflows/wf_database-handling.html">],
    #        #    ["workflow", #<Jekyll::PageWithoutAFile @relative_path="topics/proteomics/tutorials/database-handling/workflows/wf_database-handling_mycoplasma.html">]]}
    #
    # We can then choose to 'resolve' that material, i.e. collect all of the
    # relevant information that is needed for it to really be useful. This
    # includes things like tools, workflows, etc. Everything is packed into a
    # highly annotated 'material' Hash.
    #
    # You might look below and say "Wow that is ridiculously unnecessarily
    # complicated", or, maybe not. But either way, this is what is required to display a full 'learning material'
    # on the GTN, and all of the metadata that goes into it.
    #
    # Some of the highlights are:
    # - learning resource metadata (taken from tutorial if it exists, otherwise, from the slides)
    # - short ID
    # - topic information (topic name/ topic_id)
    # - any javascript requirements
    # - All associated workflows, and metadata about those workflows (tests, features used, associated test results, mermaid and dot graphs, associated tools, inputs and outputs.)
    # - +ref+, +ref_tutorials+, +ref_slides+ that point to the actual Jekyll pages, in case you need those.
    # - api URL
    # - tools (discovered from the tutorial text + workflows)
    # - a list of supported servers for easy display (exact and inexact matches)
    # - a matrix of which servers support which versions of those tools, for a full compatibility table (used on maintainer page.)
    # - requisite metdata for an admin to install these tools
    #
    #    resource = Gtn::TopicFilter.collate_materials(site, site.pages)['proteomics/database-handling']
    #    material = Gtn::TopicFilter.resolve_material(site, resource)
    #    material # =>
    #    {"layout"=>"tutorial_hands_on",
    #     "title"=>"Protein FASTA Database Handling",
    #     "edam_ontology"=>["topic_0121"],
    #     "zenodo_link"=>"",
    #     "level"=>"Introductory",
    #     "questions"=>["How to download protein FASTA databases of a certain organism?", "How to download a contaminant database?", "How to create a decoy database?", "How to combine databases?"],
    #     "objectives"=>["Creation of a protein FASTA database ready for use with database search algorithms."],
    #     "time_estimation"=>"30m",
    #     "key_points"=>
    #      ["There are several types of Uniprot databases.",
    #       "Search databases should always include possible contaminants.",
    #       "For analyzing cell culture or organic samples, search databases should include mycoplasma databases.",
    #       "Some peptide search engines depend on decoys to calculate the FDR."],
    #     "contributors"=>["stortebecker", "bgruening"],
    #     "subtopic"=>"id-quant",
    #     "tags"=>["DDA"],
    #     "js_requirements"=>{"mathjax"=>nil, "mermaid"=>false},
    #     "short_id"=>"T00214",
    #     "symlink"=>nil,
    #     "url"=>"/topics/proteomics/tutorials/database-handling/tutorial.html",
    #     "topic_name"=>"proteomics",
    #     "tutorial_name"=>"database-handling",
    #     "dir"=>"topics/proteomics/tutorials/database-handling",
    #     "redirect_from"=>["/short/proteomics/database-handling", "/short/T00214"],
    #     "id"=>"proteomics/database-handling",
    #     "ref"=>#<Jekyll::Page @relative_path="topics/proteomics/tutorials/database-handling/tutorial.md">,
    #     "ref_tutorials"=>[#<Jekyll::Page @relative_path="topics/proteomics/tutorials/database-handling/tutorial.md">],                                                                                                    "ref_slides"=>[],                                                                                                                                                                                                 "hands_on"=>true,                                                                                                                                                                                                 "slides"=>false,                                                                                                                                                                                                  "mod_date"=>2023-11-09 09:55:09 +0100,
    #     "pub_date"=>2017-02-14 13:20:30 +0100,
    #     "version"=>29,
    #     "workflows"=>
    #     "workflows"=>
    #      [{"workflow"=>"wf_database-handling.ga",
    #        "tests"=>false,
    #        "url"=>"https://training.galaxyproject.org/training-material/topics/proteomics/tutorials/database-handling/workflows/wf_database-handling.ga",
    #        "url_html"=>"https://training.galaxyproject.org/training-material/topics/proteomics/tutorials/database-handling/workflows/wf_database-handling.html",
    #        "path"=>"topics/proteomics/tutorials/database-handling/workflows/wf_database-handling.ga",
    #        "wfid"=>"proteomics-database-handling",
    #        "wfname"=>"wf-database-handling",
    #        "trs_endpoint"=>"https://training.galaxyproject.org/training-material/api/ga4gh/trs/v2/tools/proteomics-database-handling/versions/wf-database-handling",
    #        "license"=>nil,
    #        "parent_id"=>"proteomics/database-handling",
    #        "topic_id"=>"proteomics",
    #        "tutorial_id"=>"database-handling",
    #        "creators"=>[],
    #        "name"=>"Proteomics: database handling",
    #        "title"=>"Proteomics: database handling",
    #        "version"=>5,
    #        "description"=>"Protein FASTA Database Handling",
    #        "tags"=>["proteomics"],
    #        "features"=>{"report"=>nil, "subworkflows"=>false, "comments"=>false, "parameters"=>false},
    #        "workflowhub_id"=>"1204",
    #        "history"=>[],
    #        "test_results"=>nil,
    #        "modified"=>2024-03-18 12:38:44.394831189 +0100,
    #        "mermaid"=>
    #         "flowchart TD\n  0[\"Protein Database Downloader\"];\n  1[\"Protein Database Downloader\"];\n  2[\"FASTA-to-Tabular\"];\n  0 -->|output_database| 2;\n  3[\"Add column\"];\n  2 -->|output| 3;\n  4[\"Tabular
    #    -to-FASTA\"];\n  3 -->|out_file1| 4;\n  5[\"FASTA Merge Files and Filter Unique Sequences\"];\n  4 -->|output| 5;\n  1 -->|output_database| 5;\n  6[\"DecoyDatabase\"];\n  5 -->|output| 6;",
    #        "graph_dot"=>
    #         "digraph main {\n  node [fontname=\"Atkinson Hyperlegible\", shape=box, color=white,style=filled,color=peachpuff,margin=\"0.2,0.2\"];\n  edge [fontname=\"Atkinson Hyperlegible\"];\n  0[label=\"Protein Data
    #    base Downloader\"]\n  1[label=\"Protein Database Downloader\"]\n  2[label=\"FASTA-to-Tabular\"]\n  0 -> 2 [label=\"output_database\"]\n  3[label=\"Add column\"]\n  2 -> 3 [label=\"output\"]\n  4[label=\"Tabular
    #    -to-FASTA\"]\n  3 -> 4 [label=\"out_file1\"]\n  5[label=\"FASTA Merge Files and Filter Unique Sequences\"]\n  4 -> 5 [label=\"output\"]\n  1 -> 5 [label=\"output_database\"]\n  6[label=\"DecoyDatabase\"]\n  5 -
    #    > 6 [label=\"output\"]\n}",
    #        "workflow_tools"=>
    #         ["addValue",
    #          "toolshed.g2.bx.psu.edu/repos/devteam/fasta_to_tabular/fasta2tab/1.1.1",
    #          "toolshed.g2.bx.psu.edu/repos/devteam/tabular_to_fasta/tab2fasta/1.1.1",
    #          "toolshed.g2.bx.psu.edu/repos/galaxyp/dbbuilder/dbbuilder/0.3.1",
    #          "toolshed.g2.bx.psu.edu/repos/galaxyp/fasta_merge_files_and_filter_unique_sequences/fasta_merge_files_and_filter_unique_sequences/1.2.0",
    #          "toolshed.g2.bx.psu.edu/repos/galaxyp/openms_decoydatabase/DecoyDatabase/2.6+galaxy0"],
    #        "inputs"=>[],
    #        "outputs"=>
    #         [{"annotation"=>"",
    #           "content_id"=>"toolshed.g2.bx.psu.edu/repos/galaxyp/dbbuilder/dbbuilder/0.3.1",
    #           "errors"=>nil,
    #           "id"=>0,
    #           "input_connections"=>{},
    #           "inputs"=>[],
    #           "label"=>nil,
    #           "name"=>"Protein Database Downloader",
    #           "outputs"=>[{"name"=>"output_database", "type"=>"fasta"}],
    #           "position"=>{"bottom"=>380.6000061035156, "height"=>102.60000610351562, "left"=>-110, "right"=>90, "top"=>278, "width"=>200, "x"=>-110, "y"=>278},
    #           "post_job_actions"=>{},
    #           "tool_id"=>"toolshed.g2.bx.psu.edu/repos/galaxyp/dbbuilder/dbbuilder/0.3.1",
    #           "tool_shed_repository"=>{"changeset_revision"=>"c1b437242fee", "name"=>"dbbuilder", "owner"=>"galaxyp", "tool_shed"=>"toolshed.g2.bx.psu.edu"},
    #           "tool_state"=>
    #            "{\"__input_ext\": \"data\", \"chromInfo\": \"/opt/galaxy/tool-data/shared/ucsc/chrom/?.len\", \"source\": {\"from\": \"cRAP\", \"__current_case__\": 1}, \"__page__\": null, \"__rerun_remap_job_id__\":
    #    null}",
    #           "tool_version"=>"0.3.1",
    #           "type"=>"tool",
    #           "uuid"=>"6613b72c-2bab-423c-88fc-05edfe9ea8ec",
    #           "workflow_outputs"=>[{"label"=>nil, "output_name"=>"output_database", "uuid"=>"2d289b03-c396-46a2-a725-987b6c75ada9"}]},
    #          ...
    #     "api"=>"https://training.galaxyproject.org/training-material/api/topics/proteomics/tutorials/database-handling/tutorial.json",
    #     "tools"=>
    #      ["addValue",
    #       "toolshed.g2.bx.psu.edu/repos/devteam/fasta_to_tabular/fasta2tab/1.1.1",
    #       "toolshed.g2.bx.psu.edu/repos/devteam/tabular_to_fasta/tab2fasta/1.1.1",
    #       "toolshed.g2.bx.psu.edu/repos/galaxyp/dbbuilder/dbbuilder/0.3.1",
    #       "toolshed.g2.bx.psu.edu/repos/galaxyp/fasta_merge_files_and_filter_unique_sequences/fasta_merge_files_and_filter_unique_sequences/1.2.0",
    #       "toolshed.g2.bx.psu.edu/repos/galaxyp/openms_decoydatabase/DecoyDatabase/2.6+galaxy0"],
    #     "supported_servers"=>
    #      {"exact"=>[{"url"=>"https://usegalaxy.eu", "name"=>"UseGalaxy.eu", "usegalaxy"=>true}, {"url"=>"https://usegalaxy.org.au", "name"=>"UseGalaxy.org.au", "usegalaxy"=>true}],
    #       "inexact"=>[{"url"=>"https://usegalaxy.no/", "name"=>"UseGalaxy.no", "usegalaxy"=>false}]},
    #     "supported_servers_matrix"=>
    #      {"servers"=>
    #        [{"url"=>"http://aspendb.uga.edu:8085/", "name"=>"AGEseq @ AspenDB"},
    #         {"url"=>"http://motherbox.chemeng.ntua.gr/anastasia_dev/", "name"=>"ANASTASIA"},
    #          ...
    #       "tools"=>
    #        [{"id"=>"addValue",
    #          "servers"=>
    #           [{"state"=>"local", "server"=>"http://aspendb.uga.edu:8085/"},
    #            {"state"=>"missing", "server"=>"http://motherbox.chemeng.ntua.gr/anastasia_dev/"},
    #            {"state"=>"local", "server"=>"http://apostl.moffitt.org/"},
    #            {"state"=>"local", "server"=>"http://smile.hku.hk/SARGs"},
    #            {"state"=>"local", "server"=>"http://bf2i-galaxy.insa-lyon.fr:8080/"},
    #            {"state"=>"local", "server"=>"http://143.169.238.104/galaxy/"},
    #            {"state"=>"missing", "server"=>"https://iris.angers.inra.fr/galaxypub-cfbp"},
    #            {"state"=>"local", "server"=>"https://cpt.tamu.edu/galaxy-public/"},
    #            {"state"=>"missing", "server"=>"https://vm-chemflow-francegrille.eu/"},
    #            {"state"=>"local", "server"=>"https://hyperbrowser.uio.no/coloc-stats"},
    #            {"state"=>"local", "server"=>"http://corgat.cloud.ba.infn.it/galaxy"},
    #            {"state"=>"local", "server"=>"http://cropgalaxy.excellenceinbreeding.org/"},
    #            {"state"=>"local", "server"=>"http://dintor.eurac.edu/"},
    #            {"state"=>"missing", "server"=>"http://www.freebioinfo.org/"},
    #            {"state"=>"local", "server"=>"http://igg.cloud.ba.infn.it/galaxy"},
    #     "topic_name_human"=>"Proteomics",
    #     "admin_install"=>
    #      {"install_tool_dependencies"=>true,
    #       "install_repository_dependencies"=>true,
    #       "install_resolver_dependencies"=>true,
    #       "tools"=>
    #        [{"name"=>"fasta_to_tabular", "owner"=>"devteam", "revisions"=>"e7ed3c310b74", "tool_panel_section_label"=>"FASTA/FASTQ", "tool_shed_url"=>"https://toolshed.g2.bx.psu.edu/"},
    #         {"name"=>"tabular_to_fasta", "owner"=>"devteam", "revisions"=>"0a7799698fe5", "tool_panel_section_label"=>"FASTA/FASTQ", "tool_shed_url"=>"https://toolshed.g2.bx.psu.edu/"},
    #         {"name"=>"dbbuilder", "owner"=>"galaxyp", "revisions"=>"c1b437242fee", "tool_panel_section_label"=>"Get Data", "tool_shed_url"=>"https://toolshed.g2.bx.psu.edu/"},
    #         {"name"=>"fasta_merge_files_and_filter_unique_sequences", "owner"=>"galaxyp", "revisions"=>"f546e7278f04", "tool_panel_section_label"=>"FASTA/FASTQ", "tool_shed_url"=>"https://toolshed.g2.bx.psu.edu/"},
    #         {"name"=>"openms_decoydatabase", "owner"=>"galaxyp", "revisions"=>"370141bc0da3", "tool_panel_section_label"=>"Proteomics", "tool_shed_url"=>"https://toolshed.g2.bx.psu.edu/"}]},
    #     "admin_install_yaml"=>
    #      "---\ninstall_tool_dependencies: true\ninstall_repository_dependencies: true\ninstall_resolver_dependencies: true\ntools:\n- name: fasta_to_tabular\n  owner: devteam\n  revisions: e7ed3c310b74\n  tool_panel_s
    #    ection_label: FASTA/FASTQ\n  tool_shed_url: https://toolshed.g2.bx.psu.edu/\n- name: tabular_to_fasta\n  owner: devteam\n  revisions: 0a7799698fe5\n  tool_panel_section_label: FASTA/FASTQ\n  tool_shed_url: http
    #    s://toolshed.g2.bx.psu.edu/\n- name: dbbuilder\n  owner: galaxyp\n  revisions: c1b437242fee\n  tool_panel_section_label: Get Data\n  tool_shed_url: https://toolshed.g2.bx.psu.edu/\n- name: fasta_merge_files_and
    #    _filter_unique_sequences\n  owner: galaxyp\n  revisions: f546e7278f04\n  tool_panel_section_label: FASTA/FASTQ\n  tool_shed_url: https://toolshed.g2.bx.psu.edu/\n- name: openms_decoydatabase\n  owner: galaxyp\n
    #      revisions: 370141bc0da3\n  tool_panel_section_label: Proteomics\n  tool_shed_url: https://toolshed.g2.bx.psu.edu/\n",
    #     "tours"=>false,
    #     "video"=>false,
    #     "slides_recordings"=>false,
    #     "translations"=>{"tutorial"=>[], "slides"=>[], "video"=>false},
    #     "license"=>"CC-BY-4.0",
    #     "type"=>"tutorial"}





    def self.resolve_material(site, material)
      # We've already
      # looked in every /topic/*/tutorials/* folder, and turn these disparate
      # resources into a page_obj as well. Most variables are copied directly,
      # either from a tutorial, or a slides (if no tutorial is available.) This
      # means we do not (cannot) support external_slides AND external_handson.
      # This is probably a sub-optimal situation we'll end up fixing someday.
      #
      tutorials = material['resources'].select { |a| a[0] == 'tutorial' }
      slides    = material['resources'].select { |a| a[0] == 'slides' }
      tours     = material['resources'].select { |a| a[0] == 'tours' }

      # Our final "page" object (a "material")
      page = nil

      slide_has_video = false
      slide_has_recordings = false
      slide_translations = []
      page_ref = nil

      if slides.length.positive?
        page = slides.min { |a, b| a[1].path <=> b[1].path }[1]
        slide_has_video = page.data.fetch('video', false)
        slide_has_recordings = page.data.fetch('recordings', false)
        slide_translations = page.data.fetch('translations', [])
        page_ref = page
      end

      # No matter if there were slides, we override with tutorials if present.
      tutorial_translations = []
      if tutorials.length.positive?
        page = tutorials.min { |a, b| a[1].path <=> b[1].path }[1]
        tutorial_translations = page.data.fetch('translations', [])
        page_ref = page
      end

      if page.nil?
        Jekyll.logger.error '[GTN/TopicFilter] Could not process material'
        return {}
      end

      # Otherwise clone the metadata from it which works well enough.
      page_obj = page.data.dup
      page_obj['id'] = "#{page['topic_name']}/#{page['tutorial_name']}"
      page_obj['ref'] = page_ref
      page_obj['ref_tutorials'] = tutorials.map { |a| a[1] }
      page_obj['ref_slides'] = slides.map { |a| a[1] }

      id = page_obj['id']

      # Sometimes `hands_on` is set to something like `external`, in which
      # case it is important to not override it. So we only do that if the
      # key isn't already set. Then we choose to set it to a test for the
      # tutorial being present. We probably don't need to test both, but it
      # is hard to follow which keys are which and safer to test for both in
      # case someone edits the code later. If either of these exist, we can
      # automatically set `hands_on: true`
      page_obj['hands_on'] = tutorials.length.positive? if !page_obj.key?('hands_on')

      # Same for slides, if there's a resource by that name, we can
      # automatically set `slides: true`
      page_obj['slides'] = slides.length.positive? if !page_obj.key?('slides')

      all_resources = slides + tutorials
      page_obj['mod_date'] = all_resources
                             .map { |p| Gtn::ModificationTimes.obtain_time(p[1].path) }
                             .max

      page_obj['pub_date'] = all_resources
                             .map { |p| Gtn::PublicationTimes.obtain_time(p[1].path) }
                             .min

      page_obj['version'] = all_resources
                            .map { |p| Gtn::ModificationTimes.obtain_modification_count(p[1].path) }
                            .max

      folder = material['dir']

      ymls = Dir.glob("#{folder}/quiz/*.yml") + Dir.glob("#{folder}/quiz/*.yaml")
      if ymls.length.positive?
        quizzes = ymls.map { |a| a.split('/')[-1] }
        page_obj['quiz'] = quizzes.map do |q|
          quiz_data = YAML.load_file("#{folder}/quiz/#{q}")
          quiz_data['id'] = q
          quiz_data['path'] = "#{folder}/quiz/#{q}"
          quiz_data
        end
      end

      # In dev configuration, this breaks for me. Not sure why config isn't available.
      domain = if !site.config.nil? && site.config.key?('url')
                 "#{site.config['url']}#{site.config['baseurl']}"
               else
                 'http://localhost:4000/training-material/'
               end
      # Similar as above.
      workflows = Dir.glob("#{folder}/workflows/*.ga") # TODO: support gxformat2
      if workflows.length.positive?
        workflow_names = workflows.map { |a| a.split('/')[-1] }
        page_obj['workflows'] = workflow_names.map do |wf|
          wfid = "#{page['topic_name']}-#{page['tutorial_name']}"
          wfname = wf.gsub(/.ga/, '').downcase.gsub(/[^a-z0-9]/, '-')
          trs = "api/ga4gh/trs/v2/tools/#{wfid}/versions/#{wfname}"
          wf_path = "#{folder}/workflows/#{wf}"
          wf_json = JSON.parse(File.read(wf_path))
          license = wf_json['license']
          creators = wf_json['creator'] || []
          wftitle = wf_json['name']

          # /galaxy-intro-101-workflow.eu.json
          workflow_test_results = Dir.glob(wf_path.gsub(/.ga$/, '.*.json'))
          workflow_test_outputs = {}
          workflow_test_results.each do |test_result|
            server = workflow_test_results[0].match(/\.(..)\.json$/)[1]
            workflow_test_outputs[server] = JSON.parse(File.read(test_result))
          end
          workflow_test_outputs = nil if workflow_test_outputs.empty?

          wfhkey = [page['topic_name'], page['tutorial_name'], wfname].join('/')

          {
            'workflow' => wf,
            'tests' => Dir.glob("#{folder}/workflows/" + wf.gsub(/.ga/, '-test*')).length.positive?,
            'url' => "#{domain}/#{folder}/workflows/#{wf}",
            'url_html' => "#{domain}/#{folder}/workflows/#{wf.gsub(/.ga$/, '.html')}",
            'path' => wf_path,
            'wfid' => wfid,
            'wfname' => wfname,
            'trs_endpoint' => "#{domain}/#{trs}",
            'license' => license,
            'parent_id' => page_obj['id'],
            'topic_id' => page['topic_name'],
            'tutorial_id' => page['tutorial_name'],
            'creators' => creators,
            'name' => wf_json['name'],
            'title' => wftitle,
            'version' => Gtn::ModificationTimes.obtain_modification_count(wf_path),
            'description' => wf_json['annotation'],
            'tags' => wf_json['tags'],
            'features' => {
              'report' => wf_json['report'],
              'subworkflows' => wf_json['steps'].map{|_, x| x['type']}.any?{|x| x == "subworkflow"},
              'comments' => (wf_json['comments'] || []).length.positive?,
              'parameters' =>  wf_json['steps'].map{|_, x| x['type']}.any?{|x| x == "parameter_input"},
            },
            'workflowhub_id' => (site.data['workflowhub'] || {}).fetch(wfhkey, nil),
            'history' => git_log(wf_path),
            'test_results' => workflow_test_outputs,
            'modified' => File.mtime(wf_path),
            'mermaid' => mermaid(wf_json),
            'graph_dot' => graph_dot(wf_json),
            'workflow_tools' => extract_workflow_tool_list(wf_json).flatten.uniq.sort,
            'inputs' => wf_json['steps'].select { |_k, v| ['data_input', 'data_collection_input', 'parameter_input'].include? v['type'] }.map{|_, v| v},
            'outputs' => wf_json['steps'].select { |_k, v| v['workflow_outputs'] && v['workflow_outputs'].length.positive? }.map{|_, v| v},
          }
        end
      end

      # Really only used for tool list install for ephemeris, not general.
      page_obj['api'] = "#{domain}/api/topics/#{page['topic_name']}/tutorials/#{page['tutorial_name']}/tutorial.json"

      # Tool List
      #
      # This is exposed in the GTN API to help admins/devs easily get the tool
      # list for installation.
      page_obj['tools'] = []
      page_obj['tools'] += page.content.scan(/{% tool \[[^\]]*\]\(([^)]*)\)\s*%}/) if page_obj['hands_on']

      page_obj['workflows']&.each do |wf|
        wf_path = "#{folder}/workflows/#{wf['workflow']}"

        page_obj['tools'] += wf['workflow_tools']
      end
      page_obj['tools'] = page_obj['tools'].flatten.sort.uniq

      topic = site.data[page_obj['topic_name']]
      page_obj['supported_servers'] = if topic['type'] == 'use' || topic['type'] == 'basics'
                                        Gtn::Supported.calculate(site.data['public-server-tools'], page_obj['tools'])
                                      else
                                        []
                                      end

      page_obj['supported_servers_matrix'] = if topic['type'] == 'use' || topic['type'] == 'basics'
        Gtn::Supported.calculate_matrix(site.data['public-server-tools'], page_obj['tools'])
      else
        []
      end


      topic_name_human = site.data[page_obj['topic_name']]['title']
      page_obj['topic_name_human'] = topic_name_human # TODO: rename 'topic_name' and 'topic_name' to 'topic_id'
      admin_install = Gtn::Toolshed.format_admin_install(site.data['toolshed-revisions'], page_obj['tools'],
                                                         topic_name_human, site.data['toolcats'])
      page_obj['admin_install'] = admin_install
      page_obj['admin_install_yaml'] = admin_install.to_yaml

      page_obj['tours'] = tours.length.positive?
      page_obj['video'] = slide_has_video
      page_obj['slides_recordings'] = slide_has_recordings
      page_obj['translations'] = {}
      page_obj['translations']['tutorial'] = tutorial_translations
      page_obj['translations']['slides'] = slide_translations
      page_obj['translations']['video'] = slide_has_video # Just demand it?
      page_obj['license'] = 'CC-BY-4.0' if page_obj['license'].nil?
      # I feel less certain about this override, but it works well enough in
      # practice, and I did not find any examples of `type: <anything other
      # than tutorial>` in topics/*/tutorials/*/tutorial.md but that doesn't
      # make it future proof.
      page_obj['type'] = 'tutorial'

      if page_obj.key?('draft') && page_obj['draft']
        page_obj['tags'] = [] if !page_obj.key? 'tags'
        page_obj['tags'].push('work-in-progress')
      end

      page_obj
    end

    def self.process_pages(site, pages)
      # eww.
      return site.data['cache_processed_pages'] if site.data.key?('cache_processed_pages')

      materials = collate_materials(site, pages).map { |_k, v| resolve_material(site, v) }
      Jekyll.logger.info '[GTN/TopicFilter] Filling Materials Cache'
      site.data['cache_processed_pages'] = materials

      # Prepare short URLs
      shortlinks = site.data['shortlinks']
      mappings = Hash.new { |h, k| h[k] = [] }

      shortlinks.each_key do |kp|
        shortlinks[kp].each do |k, v|
          mappings[v].push("/short/#{k}")
        end
      end
      # Update the materials with their short IDs + redirects
      pages.select { |p| mappings.keys.include? p.url }.each do |p|
        # Set the short id on the material
        if p['ref']
          # Initialise redirects if it wasn't set
          p['ref'].data['redirect_from'] = [] if !p['ref'].data.key?('redirect_from')
          p['ref'].data['redirect_from'].push(*mappings[p.url])
          p['ref'].data['redirect_from'].uniq!
        else
          p.data['redirect_from'] = [] if !p.data.key?('redirect_from')

          p.data['redirect_from'].push(*mappings[p.url])
          p.data['redirect_from'].uniq!
        end
      end
      # Same for news
      get_posts(site).select { |p| mappings.keys.include? p.url }.each do |p|
        # Set the short id on the material
        p.data['redirect_from'] = [] if !p.data.key?('redirect_from')
        p.data['redirect_from'].push(*mappings[p.url])
        p.data['redirect_from'].uniq!
      end

      materials
    end

    ##
    # This is a helper function to get all the materials in a site.
    def self.list_all_materials(site)
      process_pages(site, site.pages)
    end

    ##
    # This is a helper function to get materials with automated videos.
    def self.list_videos(site)
      materials = process_pages(site, site.pages)
      materials.select { |x| x['video'] == true }
    end

    ##
    # List every tag used across all materials.
    # This is used to generate the tag cloud.
    #
    # Parameters:
    # +site+:: The +Jekyll::Site+ object, used to get the list of pages.
    # Returns:
    # +Array+:: An array of strings, each string is a tag. (sorted and unique)
    #
    def self.list_all_tags(site)
      materials = process_pages(site, site.pages)
      (materials.map { |x| x['tags'] || [] }.flatten + list_topics(site)).sort.uniq
    end

    def self.filter_by_topic(site, topic_name)
      # Here we make a (cached) call to load materials into memory and sort them
      # properly.
      materials = process_pages(site, site.pages)

      # Select out the materials by topic:
      resource_pages = materials.select { |x| x['topic_name'] == topic_name }

      # If there is nothing with that topic name, try generating it by tags.
      resource_pages = materials.select { |x| (x['tags'] || []).include?(topic_name) } if resource_pages.empty?

      # The complete resources we'll return is the introduction slides first
      # (EDIT: not anymore, we rely on prioritisation!)
      # and then the rest of the pages.
      resource_pages = resource_pages.sort_by { |k| k.fetch('priority', 1) }

      Jekyll.logger.error "Error? Could not find any relevant pages for #{topic_name}" if resource_pages.empty?

      resource_pages
    end

    def self.filter_by_tag(site, topic_name)
      # Here we make a (cached) call to load materials into memory and sort them
      # properly.
      materials = process_pages(site, site.pages)

      # Select those with that topic ID or that tag
      resource_pages = materials.select { |x| x['topic_name'] == topic_name }
      resource_pages += materials.select { |x| (x['tags'] || []).include?(topic_name) }

      # The complete resources we'll return is the introduction slides first
      # (EDIT: not anymore, we rely on prioritisation!)
      # and then the rest of the pages.
      resource_pages = resource_pages.sort_by { |k| k.fetch('priority', 1) }

      Jekyll.logger.error "Error? Could not find any relevant tagged pages for #{topic_name}" if resource_pages.empty?

      resource_pages
    end

    ##
    # Filter a list of materials by topic and subtopic.
    def self.filter_by_topic_subtopic(site, topic_name, subtopic_id)
      resource_pages = filter_by_topic(site, topic_name)

      # Select out materials with the correct subtopic
      resource_pages = resource_pages.select { |x| x['subtopic'] == subtopic_id }

      if resource_pages.empty?
        Jekyll.logger.error "Error? Could not find any relevant pages for #{topic_name} / #{subtopic_id}"
      end

      resource_pages
    end

    ##
    # Get a list of contributors for a list of materials
    # Parameters:
    # +materials+:: An array of materials
    # Returns:
    # +Array+:: An array of individual contributors as strings.
    def self.identify_contributors(materials, site)
      materials
        .map { |_k, v| v['materials'] }.flatten
        # Not 100% sure why this flatten is needed? Probably due to the map over hash
        .map { |mat| Gtn::Contributors.get_contributors(mat) }
        .flatten
        .select { |c| Gtn::Contributors.person?(site, c) }
        .uniq
        .shuffle
    end

    ##
    # Get a list of funders for a list of materials
    # Parameters:
    # +materials+:: An array of materials
    # Returns:
    # +Array+:: An array of funder (organisations that provided support) IDs as strings.
    def self.identify_funders_and_grants(materials, site)
      materials
        .map { |_k, v| v['materials'] }.flatten
        # Not 100% sure why this flatten is needed? Probably due to the map over hash
        .map { |mat| Gtn::Contributors.get_all_funding(site, mat) }
        .flatten
        .uniq
        .shuffle
    end

    ##
    # Get the version of a tool.
    # Parameters:
    # +tool+:: A tool string
    # Returns:
    # +String+:: The version of the tool.
    #
    # Examples:
    # get_version("toolshed.g2.bx.psu.edu/repos/galaxyp/regex_find_replace/regex1/1.0.0") => "1.0.0"
    def self.get_version(tool)
      if tool.count('/') > 4
        tool.split('/')[-1]
      else
        tool
      end
    end

    ##
    # Get a short version of a tool.
    # Parameters:
    # +tool+:: A tool string
    # Returns:
    # +String+:: The short version of the tool.
    #
    # Examples:
    # short_tool("toolshed.g2.bx.psu.edu/repos/galaxyp/regex_find_replace/regex1/1.0.0") => "galaxyp/regex1"
    def self.short_tool(tool)
      if tool.count('/') > 4
        "#{tool.split('/')[2]}/#{tool.split('/')[3]}/#{tool.split('/')[4]}"
      else
        tool
      end
    end

    ##
    # List materials by tool
    #
    # Parameters:
    # +site+:: The +Jekyll::Site+ object, used to get the list of pages.
    # Returns:
    # +Hash+:: A hash as below:
    #
    #   {
    #     tool_id => {
    #       "tool_id" => [tool_id, version],
    #       "tutorials" => [tutorial_id, tutorial_title, topic_title, tutorial_url]
    #     }, ...
    #   }
    #
    # *Nota Bene!!!*: Galaxy depends on the structure of this response, please
    # do not change it, add a new API instead if you need to modify it
    # significantly.
    #
    def self.list_materials_by_tool(site)
      tool_map = {}

      list_all_materials(site).each do |m|
        m.fetch('tools', []).each do |tool|
          sid = short_tool(tool)
          tool_map[sid] = { 'tool_id' => [], 'tutorials' => [] } if !tool_map.key?(sid)

          tool_map[sid]['tool_id'].push([tool, get_version(tool)])
          tool_map[sid]['tutorials'].push([
                                            m['id'], m['title'], site.data[m['topic_name']]['title'], m['url']
                                          ])
        end
      end

      # Uniqueify/sort
      t = tool_map.to_h do |k, v|
        v['tool_id'].uniq!
        v['tool_id'].sort_by! { |k2| k2[1] }
        v['tool_id'].reverse!

        v['tutorials'].uniq!
        v['tutorials'].sort!
        [k, v]
      end

      # Order by most popular tool
      t.sort_by { |_k, v| v['tutorials'].length }.reverse.to_h
    end


    ##
    # Not materials but resources (including e.g. recordings, slides separate from tutorials, etc.)
    #
    # The structure is a large array of arrays, with [date, category, page-like object, tags]
    #
    #   [#<DateTime: 2019-02-22T20:53:50+01:00 ((2458537j,71630s,0n),+3600s,2299161j)>,
    #    "tutorials",
    #    #<Jekyll::Page @relative_path="topics/single-cell/tutorials/scrna-preprocessing/tutorial.md">,
    #    ["single-cell"]],
    #   [#<DateTime: 2019-02-20T19:33:11+01:00 ((2458535j,66791s,0n),+3600s,2299161j)>,
    #    "tutorials",
    #    #<Jekyll::Page @relative_path="topics/single-cell/tutorials/scrna-umis/tutorial.md">,
    #    ["single-cell"]],
    #   [#<DateTime: 2019-02-16T21:04:07+01:00 ((2458531j,72247s,0n),+3600s,2299161j)>,
    #    "slides",
    #    #<Jekyll::Page @relative_path="topics/single-cell/tutorials/scrna-plates-batches-barcodes/slides.html">,
    #    ["single-cell"]]] 
    def self.all_date_sorted_resources(site)
      cache.getset('all_date_sorted_resources') do
        self._all_date_sorted_resources(site)
      end
    end

    def self._all_date_sorted_resources(site)
      events = site.pages.select { |x| x['layout'] == 'event' || x['layout'] == 'event-external' }
      materials = list_all_materials(site).reject { |k, _v| k['draft'] }
      news = site.posts.select { |x| x['layout'] == 'news' }
      faqs = site.pages.select { |x| x['layout'] == 'faq' }
      pathways = site.pages.select { |x| x['layout'] == 'learning-pathway' }
      workflows = Dir.glob('topics/**/*.ga')

      bucket = events.map do |e|
        [Gtn::PublicationTimes.obtain_time(e.path).to_datetime, 'events', e, ['event'] + e.data.fetch('tags', [])]
      end

      materials.each do |m|
        tags = [m['topic_name']] + (m['tags'] || [])
        m.fetch('ref_tutorials', []).map do |t|
          bucket << [Gtn::PublicationTimes.obtain_time(t.path).to_datetime, 'tutorials', t, tags]

          (t['recordings'] || []).map do |r|
            url = '/' + t.path.gsub(/tutorial(_[A_Z_]*)?.(html|md)$/, 'recordings/')
            url += "#tutorial-recording-#{Date.parse(r['date']).strftime('%-d-%B-%Y').downcase}"
            attr = {'title' => "Recording of " + t['title'], 
                    'contributors' => r['speakers'] + (r['captions'] || []),
                    'content' => "A #{r['length']} long recording is now available."}

            obj = objectify(attr, url, t.path)
            bucket << [DateTime.parse(r['date'].to_s), 'recordings', obj, tags]
          end
        end

        m.fetch('ref_slides', []).reject { |s| s.url =~ /-plain.html/ }.map do |s|
          bucket << [Gtn::PublicationTimes.obtain_time(s.path).to_datetime, 'slides', s, tags]

          (s['recordings'] || []).map do |r|
            url = '/' + s.path.gsub(/slides(_[A_Z_]*)?.(html|md)$/, 'recordings/')
            url += "#tutorial-recording-#{Date.parse(r['date']).strftime('%-d-%B-%Y').downcase}"
            attr = {'title' => "Recording of " + s['title'], 
                    'contributors' => r['speakers'] + (r['captions'] || []),
                    'content' => "A #{r['length']} long recording is now available."}
            obj = objectify(attr, url, s.path)
            bucket << [DateTime.parse(r['date'].to_s), 'recordings', obj, tags]
          end
        end
      end

      bucket += news.map do |n|
        [n.date.to_datetime, 'news', n, ['news'] + n.data.fetch('tags', [])]
      end

      bucket += faqs.map do |n|
        tag = Gtn::PublicationTimes.clean_path(n.path).split('/')[1]
        [Gtn::PublicationTimes.obtain_time(n.path).to_datetime, 'faqs', n, ['faqs', tag]]
      end

      bucket += pathways.map do |n|
        tags = ['learning-pathway'] + (n['tags'] || [])
        [Gtn::PublicationTimes.obtain_time(n.path).to_datetime, 'learning-pathways', n, tags]
      end

      bucket += workflows.map do |n|
        tag = Gtn::PublicationTimes.clean_path(n).split('/')[1]
        wf_data = JSON.parse(File.read(n))

        attrs = {
          'title' => wf_data['name'],
          'description' => wf_data['annotation'],
          'tags' => wf_data['tags'],
          'contributors' => wf_data.fetch('creator', []).map do |c|
            matched = site.data['contributors'].select{|k, v| 
              v.fetch('orcid', "does-not-exist") == c.fetch('identifier', "").gsub('https://orcid.org/', '')
            }.first
            if matched
              matched[0]
            else
              c['name']
            end
          end
        }
        # These aren't truly stable. I'm not sure what to do about that.
        obj = objectify(attrs, '/' + n.gsub(/\.ga$/, '.html'), n)
        # obj = objectify(attrs, '/' + n.path[0..n.path.rindex('/')], n)
        [Gtn::PublicationTimes.obtain_time(n).to_datetime, 'workflows', obj, ['workflows', tag] + obj['tags']]
      end

      # Remove symlinks from bucket.
      bucket = bucket.reject { |date, type, page, tags|
        File.symlink?(page.path) || File.symlink?(File.dirname(page.path)) || File.symlink?(File.dirname(File.dirname(page.path)))
      }

      bucket += site.data['contributors'].map do |k, v|
        a = {'title' => "@#{k}",
             'content' => "GTN Contributions from #{k}"}
        obj = objectify(a, "/hall-of-fame/#{k}/", k)

        [DateTime.parse("#{v['joined']}-01T12:00:00", 'content' => "GTN Contributions from #{k}"), 'contributors', obj, ['contributor']]
      end

      bucket += site.data['grants'].map do |k, v|
        a = {'title' => "@#{k}",
             'content' => "GTN Contributions from #{k}"}
        obj = objectify(a, "/hall-of-fame/#{k}/", k)

        # TODO: backdate grants, organisations
        if v['joined']
          [DateTime.parse("#{v['joined']}-01T12:00:00"), 'grants', obj, ['grant']]
        end
      end.compact

      bucket += site.data['organisations'].map do |k, v|
        a = {'title' => "@#{k}",
             'content' => "GTN Contributions from #{k}"}
        obj = objectify(a, "/hall-of-fame/#{k}/", k)

        if v['joined']
          [DateTime.parse("#{v['joined']}-01T12:00:00"), 'organisations', obj, ['organisation']]
        end
      end.compact

      bucket
        .reject{|x| x[0] > DateTime.now } # Remove future-dated materials
        .reject{|x| x[2]['draft'] == true } # Remove drafts
        .sort_by {|x| x[0] } # Date-sorted, not strictly necessary since will be grouped.
        .reverse
    end
  end
end

module Jekyll
  # The "implementation" of the topic filter as liquid accessible filters
  module Filters
    module TopicFilter
      ##
      # List the most recent contributors to the GTN.
      # Parameters:
      # +contributors+:: A hash of contributors
      # +count+:: The number of contributors to return
      # Returns:
      # +Hash+:: A hash of contributors
      #
      # Example:
      # most_recent_contributors(contributors, 5)
      # => {
      #  "hexylena" => {
      #  "name" => "Hexylena",
      #  "avatar" => "https://avatars.githubusercontent.com/u/458683?v=3",
      #  ...
      #  }
      # }
      def most_recent_contributors(contributors, count)
        # Remove non-hof
        hof = contributors.reject { |_k, v| v.fetch('halloffame', 'yes') == 'no' }
        # Get keys + sort by joined date
        hof_k = hof.keys.sort do |x, y|
          hof[y].fetch('joined', '2016-01') <=> hof[x].fetch('joined', '2016-01')
        end

        # Transform back into hash
        hof_k.slice(0, count).to_h { |k| [k, hof[k]] }
      end

      ##
      # Find the most recently modified tutorials
      # Parameters:
      # +site+:: The +Jekyll::Site+ object, used to get the list of pages.
      # +exclude_recently_published+:: Do not include ones that were recently
      #                                published in the slice, to make it look a bit nicer.
      # Returns:
      # +Array+:: An array of the 10 most recently modified pages
      # Example:
      #  {% assign latest_tutorials = site | recently_modified_tutorials %}
      def recently_modified_tutorials(site, exclude_recently_published: true)
        tutorials = site.pages.select { |page| page.data['layout'] == 'tutorial_hands_on' }

        latest = tutorials.sort do |x, y|
          Gtn::ModificationTimes.obtain_time(y.path) <=> Gtn::ModificationTimes.obtain_time(x.path)
        end

        latest_published = recently_published_tutorials(site)
        latest = latest.reject { |x| latest_published.include?(x) } if exclude_recently_published

        latest.slice(0, 10)
      end

      ##
      # Find the most recently published tutorials
      # Parameters:
      # +site+:: The +Jekyll::Site+ object, used to get the list of pages.
      # Returns:
      # +Array+:: An array of the 10 most recently published modified pages
      # Example:
      #  {% assign latest_tutorials = site | recently_modified_tutorials %}
      def recently_published_tutorials(site)
        tutorials = site.pages.select { |page| page.data['layout'] == 'tutorial_hands_on' }

        latest = tutorials.sort do |x, y|
          Gtn::PublicationTimes.obtain_time(y.path) <=> Gtn::PublicationTimes.obtain_time(x.path)
        end

        latest.slice(0, 10)
      end

      def topic_count(resources)
        # Count lines in the table except introduction slides
        resources.length
      end

      ##
      # Fetch a tutorial material's metadata
      # Parameters:
      # +site+:: The +Jekyll::Site+ object, used to get the list of pages.
      # +topic_name+:: The name of the topic
      # +page_name+:: The name of the page
      # Returns:
      # +Hash+:: The metadata for the tutorial material
      #
      # Example:
      #  {% assign material = site | fetch_tutorial_material:page.topic_name,page.tutorial_name%}
      def fetch_tutorial_material(site, topic_name, page_name)
        Gtn::TopicFilter.fetch_tutorial_material(site, topic_name, page_name)
      end

      def fetch_tutorial_material_by_id(site, id)
        Gtn::TopicFilter.fetch_tutorial_material(site, id.split('/')[0], id.split('/')[1])
      end

      def list_topics_ids(site)
        ['introduction'] + Gtn::TopicFilter.list_topics(site).filter { |k| k != 'introduction' }
      end

      def list_topics_h(site)
        Gtn::TopicFilter.list_topics(site)
      end

      def list_topics_by_category(site, category)
        q = Gtn::TopicFilter.list_topics(site).map do |k|
          [k, site.data[k]]
        end

        # Alllow filtering by a category, or return "all" otherwise.
        if category == 'non-tag'
          q = q.select { |_k, v| v['tag_based'].nil? }
        elsif category == 'science'
          q = q.select { |_k, v| %w[use basics].include? v['type'] }
        elsif category == 'technical'
          q = q.select { |_k, v| %w[admin-dev data-science instructors].include? v['type'] }
        elsif category == 'science-technical'
          q = q.select { |_k, v| %w[use basics admin-dev data-science instructors].include? v['type'] }
        elsif category != 'all'
          q = q.select { |_k, v| v['type'] == category }
        end

        # Sort alphabetically by titles
        q.sort { |a, b| a[1]['title'] <=> b[1]['title'] }
      end

      def to_keys(arr)
        arr.map { |k| k[0] }
      end

      def to_vals(arr)
        arr.map { |k| k[1] }
      end

      ##
      # Galaxy depends on the structure of this response, please do not change
      # it, add a new API instead if you need to modify it significantly.
      def list_materials_by_tool(site)
        Gtn::TopicFilter.list_materials_by_tool(site)
      end

      def list_materials_structured(site, topic_name)
        Gtn::TopicFilter.list_materials_structured(site, topic_name)
      end

      def list_materials_flat(site, topic_name)
        Gtn::TopicFilter
          .list_materials_structured(site, topic_name)
          .map { |k, v| v['materials'] }
          .flatten
          .uniq { |x| x['id'] }
      end

      def list_topic_materials_yearly(site, topic_name)
        flat_mats = list_materials_flat(site, topic_name)
        years = flat_mats.map{|x| x['pub_date'].year} + flat_mats.map{|x| x['mod_date'].year}
        # doesn't use identify_contributors because that excludes grants/orgs.
        topic_contribs = flat_mats.map{|x| x['contributions']  || {"all" => x['contributors']}}.map{|x| x.values.flatten}.flatten.uniq.sort
        pfo = ['contributors', 'grants', 'organisations']

        Gtn::TopicFilter.all_date_sorted_resources(site)
          .select{|x| (x[3].include? topic_name) || (pfo.include?(x[1]) && topic_contribs.include?(x[2].title[1..]))}
          .group_by{|x| x[0].year}
          .map{|k, v| [k, v.group_by{|z| z[1]}]}
          .to_h
      end

      def count_topic_materials_yearly(site, topic_name)
        flat_mats = list_materials_flat(site, topic_name)
        years = flat_mats.map{|x| x['pub_date'].year} + flat_mats.map{|x| x['mod_date'].year}
        # doesn't use identify_contributors because that excludes grants/orgs.
        topic_contribs = flat_mats.map{|x| x['contributions']  || {"all" => x['contributors']}}.map{|x| x.values.flatten}.flatten.uniq.sort
        pfo = ['contributors', 'grants', 'organisations']

        r = Gtn::TopicFilter.all_date_sorted_resources(site)
          .select{|x| (x[3].include? topic_name) || (pfo.include?(x[1]) && topic_contribs.include?(x[2].title[1..]))}
          .map{|x| [x[0].year, x[1]]} # Only need year + type
          .group_by{|x| x[1]} # Group by type.
          .map{|k, v| [k, v.map{|vv| vv[0]}.tally]}
          .to_h

        years = (2015..Date.today.year).to_a
        # Fill in zeros for missing years
        r.map{|k, v| [k, years.map{|y| v[y] || 0}
          .cumulative_sum
          .map.with_index{|value, i| {"y" => value, "x" => "#{years[i]}-01-01"}}]
        }.to_h
      end

      def list_all_tags(site)
        Gtn::TopicFilter.list_all_tags(site)
      end

      def topic_filter(site, topic_name)
        Gtn::TopicFilter.topic_filter(site, topic_name)
      end

      def topic_filter_tutorial_count(site, topic_name)
        Gtn::TopicFilter.topic_filter(site, topic_name).length
      end

      def identify_contributors(materials, site)
        Gtn::TopicFilter.identify_contributors(materials, site)
      end

      def identify_funders(materials, site)
        Gtn::TopicFilter.identify_funders_and_grants(materials, site)
      end

      ##
      # Just used for stats page.
      def list_videos(site)
        Gtn::TopicFilter.list_all_materials(site)
          .select { |k, _v| k['recordings'] || k['slides_recordings'] }
          .map { |k, _v| (k['recordings'] || []) + (k['slides_recordings'] || []) }
          .flatten
      end

      def findDuration(duration)
        if ! duration.nil?
          eval(duration.gsub(/H/, ' * 3600 + ').gsub(/M/, ' * 60 + ').gsub(/S/, ' + ') + " 0")
        else
          0
        end
      end

      ##
      # Just used for stats page.
      def list_videos_total_time(site)
        vids = list_videos(site)
        vids.map { |v| findDuration(v['length']) }.sum / 3600.0
      end

      def list_draft_materials(site)
        Gtn::TopicFilter.list_all_materials(site).select { |k, _v| k['draft'] }
      end

      def to_material(site, page)
        topic = page['path'].split('/')[1]
        material = page['path'].split('/')[3]
        ret = Gtn::TopicFilter.fetch_tutorial_material(site, topic, material)
        Jekyll.logger.warn "Could not find material #{topic} #{material}" if ret.nil?
        ret
      end

      def get_workflow(site, page, workflow)
        mat = to_material(site, page)
        mat['workflows'].select { |w| w['workflow'] == workflow }[0]
      end

      def tool_version_support(site, tool)
        Gtn::Supported.calculate(site.data['public-server-tools'], [tool])
      end

      def edamify(term, site)
        site.data['EDAM'].select{|row| row['Class ID'] == "http://edamontology.org/#{term}"}.first.to_h
      end

      def titlecase(term)
        term.split(' ').map(&:capitalize).join(' ')
      end
    end
  end
end

Liquid::Template.register_filter(Jekyll::Filters::TopicFilter)
