module Trestle
  module SimpleMDE
    class Field < Trestle::Form::Fields::TextArea
      def defaults
        super.merge(rows: 5, class: "simplemde")
      end
    end
  end
end