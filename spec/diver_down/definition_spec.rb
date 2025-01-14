# frozen_string_literal: true

RSpec.describe DiverDown::Definition do
  describe 'ClassMethods' do
    describe '.from_hash' do
      it 'loads hash' do
        definition = described_class.new(
          title: 'title',
          definition_group: 'x',
          sources: [
            DiverDown::Definition::Source.new(
              source_name: 'a.rb',
              dependencies: [
                DiverDown::Definition::Dependency.new(
                  source_name: 'b.rb'
                ),
                DiverDown::Definition::Dependency.new(
                  source_name: 'c.rb'
                ),
              ]
            ),
          ]
        )

        expect(described_class.from_hash(definition.to_h)).to eq(definition)
      end
    end

    describe '.combine' do
      it 'combines definitions' do
        definition_1 = described_class.new(
          title: 'title',
          sources: [
            DiverDown::Definition::Source.new(
              source_name: 'a.rb',
              dependencies: [
                DiverDown::Definition::Dependency.new(
                  source_name: 'b.rb'
                ),
                DiverDown::Definition::Dependency.new(
                  source_name: 'c.rb'
                ),
              ]
            ),
          ]
        )

        definition_2 = described_class.new(
          title: 'title',
          sources: [
            DiverDown::Definition::Source.new(
              source_name: 'd.rb',
              dependencies: [
                DiverDown::Definition::Dependency.new(
                  source_name: 'e.rb'
                ),
                DiverDown::Definition::Dependency.new(
                  source_name: 'f.rb'
                ),
              ]
            ),
          ]
        )

        definition = described_class.combine(
          definition_group: 'definition_group',
          title: 'title',
          definitions: [definition_1, definition_2]
        )

        expect(definition.title).to eq('title')
        expect(definition.definition_group).to eq('definition_group')
        expect(definition.sources.length).to eq(2)
        expect(definition.sources[0].source_name).to eq('a.rb')
        expect(definition.sources[1].source_name).to eq('d.rb')
      end
    end
  end

  describe 'InstanceMethods' do
    describe '#find_or_build_source' do
      it 'finds or builds source' do
        definition = described_class.new
        expect(definition.sources.length).to eq(0)

        source_1 = definition.find_or_build_source('a.rb')
        expect(definition.sources.length).to eq(1)

        source_2 = definition.find_or_build_source('a.rb')
        expect(definition.sources.length).to eq(1)
        expect(source_1).to eq(source_2)

        definition.find_or_build_source('b.rb')
        expect(definition.sources.length).to eq(2)
      end
    end

    describe '#source' do
      it 'finds source by source name' do
        definition = described_class.new
        expect(definition.source('a.rb')).to be_nil

        source_1 = definition.find_or_build_source('a.rb')
        expect(definition.source(source_1.source_name)).to eq(source_1)
      end
    end

    describe '#to_h' do
      it 'converts definition to hash' do
        definition = described_class.new(
          title: 'title',
          definition_group: 'xxx',
          sources: [
            DiverDown::Definition::Source.new(
              source_name: 'a.rb',
              dependencies: [
                DiverDown::Definition::Dependency.new(
                  source_name: 'b.rb',
                  method_ids: [
                    DiverDown::Definition::MethodId.new(
                      name: 'A',
                      context: 'class',
                      paths: ['a.rb']
                    ),
                  ]
                ),
                DiverDown::Definition::Dependency.new(
                  source_name: 'c.rb'
                ),
              ]
            ),
          ]
        )

        expect(definition.to_h).to eq(
          title: definition.title,
          definition_group: 'xxx',
          sources: [
            {
              source_name: 'a.rb',
              dependencies: [
                {
                  source_name: 'b.rb',
                  method_ids: [
                    {
                      name: 'A',
                      context: 'class',
                      paths: ['a.rb'],
                    },
                  ],
                }, {
                  source_name: 'c.rb',
                  method_ids: [],
                },
              ],
            },
          ]
        )
      end
    end

    describe '#hash' do
      it 'returns a hash' do
        definition = described_class.new(
          title: 'title',
          sources: [
            DiverDown::Definition::Source.new(
              source_name: 'a.rb',
              dependencies: [
                DiverDown::Definition::Dependency.new(
                  source_name: 'b.rb',
                  method_ids: [
                    DiverDown::Definition::MethodId.new(
                      name: 'A',
                      context: 'class',
                      paths: ['a.rb']
                    ),
                  ]
                ),
                DiverDown::Definition::Dependency.new(
                  source_name: 'c.rb'
                ),
              ]
            ),
          ]
        )

        expect(definition.hash).to eq(definition.dup.hash)

        definition.store_id = 1
        expect(definition.hash).to eq(definition.dup.hash)

        same_store_id = described_class.new
        same_store_id.store_id = 1
        expect(definition.hash).to eq(same_store_id.hash)

        different_store_id = described_class.new
        different_store_id.store_id = 2
        expect(definition.hash).to_not eq(different_store_id.hash)
      end
    end
  end
end
