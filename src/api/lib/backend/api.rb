# API for accessing to the backend
module Backend
  class Api
    # Returns the attribute content (from src/api/app/controllers/attribute_controller.rb)
    def self.attribute(project, package, revision)
      path = "/source/#{CGI.escape(project)}/#{CGI.escape(package || '_project')}/_attribute?meta=1"
      path += "&rev=#{CGI.escape(revision)}" if revision
      Backend::Connection.get(path).body
    end

    # Writes the xml for attributes (from src/api/app/mixins/has_attributes.rb)
    def self.write_attributes(project, package, login, xml, comment)
      path = "/source/#{CGI.escape(project)}/#{CGI.escape(package || '_project')}/_attribute?meta=1&user=#{CGI.escape(login)}"
      path += "&comment=#{CGI.escape(comment)}" if comment
      Backend::Connection.put(path, xml)
    end

    # Returns a file list (from src/api/app/controllers/build/file_controller.rb)
    def self.file_list(project, repository, arch, package)
      Backend::Connection.get("/build/#{CGI.escape(project)}/#{CGI.escape(repository)}/#{CGI.escape(arch)}/#{CGI.escape(package)}").body
    end

    # Returns the revisions list for a package / project using mrev (from src/api/app/helpers/validation_helper.rb)
    def self.revisions_list(project, package = nil)
      Backend::Connection.get("/source/#{CGI.escape(project)}/#{CGI.escape(package || '_project')}/_history?deleted=1&meta=1").body
    end

    # Returns the meta file from a deleted project (from src/api/app/helpers)
    def self.meta_from_deleted_project(project, revision)
      Backend::Connection.get("/source/#{CGI.escape(project)}/_project/_meta?rev=#{CGI.escape(revision)}&deleted=1").body
    end

    # It triggers all the services of a package (from src/api/app/controllers/webui/package_controller.rb)
    def self.trigger_services(project, package, user)
      Backend::Connection.post("/source/#{CGI.escape(project)}/#{CGI.escape(package)}?cmd=runservice&user=#{CGI.escape(user)}")
    end

    # Returns the notification payload for that key (from src/api/app/models/binary_release.rb)
    def self.notification_payload(key)
      Backend::Connection.get("/notificationpayload/#{key}").body
    end

    # Deletes the notification payload for that key (from src/api/app/models/binary_release.rb)
    def self.delete_notification_payload(key)
      Backend::Connection.delete("/notificationpayload/#{key}")
    end

    # Returns the patchinfo for that reference
    def self.patchinfo(reference)
      Backend::Connection.get("/source/#{CGI.escape(reference)}/_patchinfo").body
    end

    # Writes the patchinfo
    def self.write_patchinfo(project, package, login, xml, comment = nil)
      path = "/source/#{CGI.escape(project)}/#{CGI.escape(package)}/_patchinfo?user=#{CGI.escape(login)}"
      path += "&comment=#{CGI.escape(comment)}" if comment
      Backend::Connection.put(path, xml)
    end

    # It writes the configuration XML
    def self.write_configuration(xml)
      Backend::Connection.put('/configuration', xml)
    end

    # Performs a search of the binary in a project list
    def self.binary_search(projects, name)
      project_list = projects.map { |project| "@project='#{CGI.escape(project.name)}'" }.join('+or+')
      Backend::Connection.post("/search/published/binary/id?match=(@name='#{CGI.escape(name)}'+and+(#{project_list}))").body
    end
  end
end
