# frozen_string_literal: true

RSpec.describe Diverdown::Definition::Source do
  describe 'ClassMethods' do
    describe '.from_hash' do
      it 'loads hash' do
        source = Diverdown::Definition::Source.new(
          source: 'a.rb',
          dependencies: [
            Diverdown::Definition::Dependency.new(
              source: 'b.rb',
              method_ids: [
                Diverdown::Definition::MethodId.new(
                  name: 'A',
                  context: 'class',
                  paths: ['a.rb']
                ),
              ]
            ),
            Diverdown::Definition::Dependency.new(
              source: 'c.rb'
            ),
          ],
          modules: [
            Diverdown::Definition::Modulee.new(
              name: 'A'
            ),
          ]
        )

        expect(described_class.from_hash(source.to_h)).to eq(source)
      end
    end

    describe '.combine' do
      it 'combines simple sources' do
        source_a = described_class.new(
          source: 'a.rb'
        )

        source_b = described_class.new(
          source: 'a.rb'
        )

        expect(described_class.combine(source_a, source_b)).to eq(
          described_class.new(
            source: 'a.rb'
          )
        )
      end

      it 'raises exception if sources are empty' do
        expect { described_class.combine }.to raise_error(ArgumentError, 'sources are empty')
      end

      it 'raises exception if source is unmatched' do
        source_a = described_class.new(
          source: 'a.rb'
        )

        source_b = described_class.new(
          source: 'b.rb'
        )

        expect { described_class.combine(source_a, source_b) }.to raise_error(ArgumentError, 'sources are unmatched. (["a.rb", "b.rb"])')
      end

      it 'combines sources with dependencies' do
        source_a = described_class.new(
          source: 'a.rb',
          dependencies: [
            Diverdown::Definition::Dependency.new(
              source: 'b.rb'
            ),
            Diverdown::Definition::Dependency.new(
              source: 'c.rb'
            ),
          ]
        )

        source_b = described_class.new(
          source: 'a.rb',
          dependencies: [
            Diverdown::Definition::Dependency.new(
              source: 'b.rb',
              method_ids: [
                Diverdown::Definition::MethodId.new(
                  name: 'to_s',
                  context: 'class',
                  paths: ['a.rb']
                ),
              ]
            ),
            Diverdown::Definition::Dependency.new(
              source: 'd.rb'
            ),
          ]
        )

        expect(described_class.combine(source_a, source_b)).to eq(
          described_class.new(
            source: 'a.rb',
            dependencies: [
              Diverdown::Definition::Dependency.new(
                source: 'b.rb',
                method_ids: [
                  Diverdown::Definition::MethodId.new(
                    name: 'to_s',
                    context: 'class',
                    paths: ['a.rb']
                  ),
                ]
              ),
              Diverdown::Definition::Dependency.new(
                source: 'c.rb'
              ),
              Diverdown::Definition::Dependency.new(
                source: 'd.rb'
              ),
            ]
          )
        )
      end
    end
  end

  describe 'InstanceMethods' do
    describe '#find_or_build_dependency' do
      it 'adds non-duplicated dependencies' do
        source = described_class.new(source: 'a.rb')
        dependency_1 = source.find_or_build_dependency('b.rb')
        dependency_2 = source.find_or_build_dependency('b.rb')

        expect(source.dependencies).to eq(
          [
            Diverdown::Definition::Dependency.new(
              source: 'b.rb'
            ),
          ]
        )
        expect(dependency_1).to eq(dependency_2)
      end

      it "doesn't add self" do
        source = described_class.new(source: 'a.rb')
        dependency = source.find_or_build_dependency('a.rb')

        expect(source.dependencies).to eq([])
        expect(dependency).to be_nil
      end
    end

    describe '#dependency' do
      it 'returns dependency if it is found' do
        source = described_class.new(source: 'a.rb')
        dependency = source.find_or_build_dependency('b.rb')

        expect(source.dependency(dependency.source)).to eq(dependency)
        expect(source.dependency('unknown')).to be_nil
      end
    end

    describe '#module' do
      it 'adds non-duplicated dependencies' do
        source = described_class.new(source: 'a.rb')
        module_1 = source.module('A')
        module_2 = source.module('A')

        expect(source.modules).to eq(
          [
            Diverdown::Definition::Modulee.new(
              name: 'A'
            ),
          ]
        )
        expect(module_1).to eq(module_2)
      end
    end

    describe '#<=>' do
      it 'compares sources' do
        sources = [
          described_class.new(source: 'a.rb'),
          described_class.new(source: 'b.rb'),
          described_class.new(source: 'c.rb'),
        ]

        expect(sources.shuffle.sort).to eq(sources)
      end
    end

    describe '#hash' do
      it 'returns a hash' do
        source = described_class.new(source: 'a.rb')

        expect(source.hash).to eq(source.dup.hash)
      end
    end

    describe '#to_h' do
      it 'returns a yaml' do
        source = described_class.new(
          source: 'a.rb',
          dependencies: [
            Diverdown::Definition::Dependency.new(
              source: 'b.rb',
              method_ids: [
                Diverdown::Definition::MethodId.new(
                  name: 'A',
                  context: 'class',
                  paths: ['a.rb']
                ),
              ]
            ),
          ],
          modules: [
            Diverdown::Definition::Modulee.new(
              name: 'A'
            ),
          ]
        )

        expect(source.to_h).to eq(
          source: 'a.rb',
          dependencies: [
            {
              source: 'b.rb',
              method_ids: [
                {
                  name: 'A',
                  context: 'class',
                  paths: ['a.rb'],
                },
              ],
            },
          ],
          modules: [
            {
              name: 'A',
            },
          ]
        )
      end
    end
  end
end
