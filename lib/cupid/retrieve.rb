class Cupid
  module Retrieve
    EMAIL_FIELDS        = %w(ID Name)
    EMAIL_FOLDER_FIELDS = %w(ID Name ParentFolder.ID ParentFolder.Name)

    def retrieve(type, fields, options={})
      post :retrieve, :retrieve_request => {
        :object_type => type,
        :properties => fields,
        'ClientIDs' => { 'ID' => account }
      }.merge(options)
    end

    def retrieve_email_folders(fields = EMAIL_FOLDER_FIELDS)
      retrieve 'DataFolder', fields, filter_email_folders
    end

    def retrieve_emails(name=nil, fields = EMAIL_FIELDS)
      retrieve 'Email', fields, filter_email_like(name)
    end

    private

    def filter_email_folders
      filter 'ContentType', 'like', 'email'
    end

    def filter_email_like(name)
      filter 'Name', 'like', name
    end
  end
end
