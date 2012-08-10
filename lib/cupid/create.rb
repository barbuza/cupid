class Cupid
  module Create
    def create(type, data)
      resource :create, server.object(type, data)
    end

    def create_folder(title, parent, options={})
      create 'DataFolder', folder(title, parent, options)
    end

    def create_email(title, body, options={})
      create 'Email', email(title, body, options)
    end

    def create_delivery(email, list)
      create 'Send', delivery(email, list)
    end

    def create_list(name)
      raise ArgumentError unless name
      response = create "List", :list_name => name
      list_id = response.data[:id].to_i
      retrieve_first(:List){ id == list_id }
    end

    def create_path(*folder_names)
      all_folders = folders
      children = all_folders.reject &:parent_id
      folder_names.inject(nil) do |parent, name|
        folder = children.find{ |f| f.name == name }
        children = if folder
          all_folders.select{ |f| f.parent_id == folder.id }
        else
          []
        end
        folder or create_folder(name, parent.id)
      end
    end

    def create_import_definition(name, list_id, source_key, filename)
      resp = create "ImportDefinition", import_definition(name, list_id, source_key, filename)
      Cupid::Models::ImportDefinition.new self, resp.data
    end

    private

    def folder(title, parent, options)
      raise ArgumentError unless title and parent and options

      {
        :name           => title,
        :content_type   => :email,
        :description    => nil,
        :is_active      => true,
        :is_editable    => true,
        :allow_children => true,
        :parent_folder  => {
          'ID' => parent
        }
      }.merge options
    end

    def email(title, body, options)
      raise ArgumentError unless title and body and options

      {
        :email_type    => 'HTML',
        :character_set => 'utf-8',
        :subject       => title,
        'HTMLBody'     => body,
        'IsHTMLPaste'  => true
      }.merge options
    end

    def delivery(email, list)
      raise ArgumentError unless email and list

      {
        :email => { 'ID' => email },
        :list  => { 'ID' => list }
      }
    end

    def import_definition(name, list_id, source_key, filename)
      raise ArgumentError unless name and list_id and source_key and filename
      {
        :name => name,
        :customer_key => name,
        :retrieve_file_transfer_location => {
          :customer_key => source_key
        },
        :destination_object => {
          :ID => list_id
        },
        :field_mapping_type => "InferFromColumnHeadings",
        :allow_errors => true,
        :file_spec => filename,
        :file_type => "CSV",
        :update_type => "AddAndDoNotUpdate",
        :attributes! => {
          :destination_object => { "xsi:type" => "List" }
        }
      }
    end

  end
end
