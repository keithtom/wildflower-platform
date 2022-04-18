namespace :search do
  desc 'Re-index objects for search'

  task reindex: "searchkick:reindex:all" do
  end
end
