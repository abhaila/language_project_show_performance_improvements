# frozen_string_literal: true

module Words
  class ImportFromText
    class << self
      def call(text, language)
        # 1. Benchmark my code performance and observe logs
        # 2. Reduce database calls
        # 2a. Reduce query count
        # 2b. Reduce write operations
        # 3. Create from model rather than association
        # 4. Reduce the number of iterations
        # 5. Transforming the data to make it a quicker process (hashes vs. arrays)

        all_words = text.split(Word::REGEX).filter_map do |word|
          word.empty? ? nil : word.downcase
        end

        db_words = language.words.where(name: all_words).index_by(&:name)

        ActiveRecord::Base.transaction do
          all_words.each do |word|
            db_word = db_words[word]
            next if db_word

            db_words[word] = Word.create(name: word, language: language)
          end
        end

        # In the meet-up we alternatively discussed the following code snippet:
        # all_words_array = all_words.uniq.map { |word| { name: word, language_id: language.id } }
        # Word.insert_all(all_words_array)
        # this significantly reduces the number of iterations and write operations
        # by negotiating with the database in one call
        # it however does skip all validations and callbacks
      end
    end
  end
end
