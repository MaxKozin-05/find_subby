# frozen_string_literal: true

SimpleForm.setup do |config|
  config.wrappers :tailwind, tag: 'div', class: 'mb-6' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label, class: 'block text-sm font-medium text-gray-700 mb-2'
    b.use :input, class: 'w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500'
    b.use :error, wrap_with: { tag: 'p', class: 'mt-2 text-sm text-red-600' }
    b.use :hint, wrap_with: { tag: 'p', class: 'mt-1 text-sm text-gray-500' }
  end

  config.wrappers :tailwind_select, tag: 'div', class: 'mb-6' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label, class: 'block text-sm font-medium text-gray-700 mb-2'
    b.use :input, class: 'w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 bg-white'
    b.use :error, wrap_with: { tag: 'p', class: 'mt-2 text-sm text-red-600' }
    b.use :hint, wrap_with: { tag: 'p', class: 'mt-1 text-sm text-gray-500' }
  end

  config.wrappers :tailwind_textarea, tag: 'div', class: 'mb-6' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label, class: 'block text-sm font-medium text-gray-700 mb-2'
    b.use :input, class: 'w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 resize-vertical'
    b.use :error, wrap_with: { tag: 'p', class: 'mt-2 text-sm text-red-600' }
    b.use :hint, wrap_with: { tag: 'p', class: 'mt-1 text-sm text-gray-500' }
  end

  config.wrappers :tailwind_file, tag: 'div', class: 'mb-6' do |b|
    b.use :html5
    b.use :label, class: 'block text-sm font-medium text-gray-700 mb-2'
    b.use :input, class: 'block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100'
    b.use :error, wrap_with: { tag: 'p', class: 'mt-2 text-sm text-red-600' }
    b.use :hint, wrap_with: { tag: 'p', class: 'mt-1 text-sm text-gray-500' }
  end

  config.default_wrapper = :tailwind
  config.boolean_style = :nested
  config.button_class = 'w-full bg-blue-600 text-white text-xl font-semibold py-4 px-6 rounded-lg hover:bg-blue-700 transition-colors cursor-pointer'
  config.boolean_label_class = 'checkbox'
  config.error_notification_tag = :div
  config.error_notification_class = 'error_notification'
  config.browser_validations = false
  config.generate_additional_classes_for = []
end
