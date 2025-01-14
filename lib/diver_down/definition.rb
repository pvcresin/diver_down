# frozen_string_literal: true

require 'securerandom'

module DiverDown
  class Definition
    require 'diver_down/definition/source'
    require 'diver_down/definition/dependency'
    require 'diver_down/definition/method_id'

    # @param hash [Hash]
    # @return [DiverDown::Definition]
    def self.from_hash(hash)
      new(
        title: hash[:title] || hash['title'] || '',
        definition_group: hash[:definition_group] || hash['definition_group'],
        sources: (hash[:sources] || hash['sources'] || []).map do |source_hash|
          DiverDown::Definition::Source.from_hash(source_hash)
        end
      )
    end

    # @param definition_group [String, nil]
    # @param title [String]
    # @param definitions [Array<DiverDown::Definition>]
    def self.combine(definition_group:, title:, definitions: [])
      all_sources = definitions.flat_map(&:sources)

      sources = all_sources.group_by(&:source_name).map do |_, same_sources|
        DiverDown::Definition::Source.combine(*same_sources)
      end

      new(
        definition_group:,
        title:,
        sources:
      )
    end

    attr_reader :definition_group, :title

    # ID issued when stored in DiverDown::Web::DefinitionStore
    # I want to manage ID in DiverDown::Web::DefinitionStore, but for performance reasons, I have to set Definition#id to determine its identity
    # because naive comparing the identity by instance variables of Definitions is slow.
    # @attr_accessor [Integer]
    attr_accessor :store_id

    # @param title [String]
    # @param sources [Array<DiverDown::Definition::Source>]
    def initialize(definition_group: nil, title: '', sources: [])
      @definition_group = definition_group
      @title = title
      @source_map = sources.map { [_1.source_name, _1] }.to_h
    end

    # @param source_name [String]
    # @return [DiverDown::Definition::Source]
    def find_or_build_source(source_name)
      @source_map[source_name] ||= DiverDown::Definition::Source.new(source_name:)
    end

    # @param source_name [String]
    # @return [DiverDown::Definition::Source, nil]
    def source(source_name)
      @source_map[source_name]
    end

    # @return [Array<DiverDown::Definition::Source>]
    def sources
      @source_map.values.sort
    end

    # @return [String]
    def to_h
      {
        definition_group:,
        title:,
        sources: sources.map(&:to_h),
      }
    end

    # @param other [Object, DiverDown::Definition::Source]
    # @return [Boolean]
    def ==(other)
      if store_id
        other.is_a?(self.class) &&
          store_id == other.store_id
      else
        other.is_a?(self.class) &&
          definition_group == other.definition_group &&
          title == other.title &&
          sources.sort == other.sources.sort
      end
    end
    alias eq? ==
    alias eql? ==

    # @return [Integer]
    def hash
      if store_id
        [self.class, store_id].hash
      else
        [self.class, definition_group, title, sources].hash
      end
    end
  end
end
