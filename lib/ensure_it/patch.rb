module EnsureIt
  if ENSURE_IT_REFINED
    def self.patch(target, &block)
      module_eval do
        refine target do
          class_eval(&block)
        end
      end
    end
  else
    def self.patch(target, &block)
      target.class_eval(&block)
    end
  end

  private_class_method :patch
end
