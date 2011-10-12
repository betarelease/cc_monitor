require "rexml/document"
require 'net/https'
require 'uri'
require 'ostruct'
require 'base64'

class CCTray
  include CruiseControlAdapter
  
  def builds(feed)
    projects = []
    parse(feed) { |element| projects << refine(element) }
    projects
  end

  def pipelines(feed)
    successful_builds, projects = filter(projects)
    group(projects)
  end

  def broken(feed)
    successful_builds, broken_builds = filter(feed)
    group(broken_builds).select { |name, stages| PIPELINES.include? name }
  end
  
  def passing(feed)
    successful_builds, broken_builds = filter(feed)     
    group(successful_builds).select { |name, stages| PIPELINES.include? name }
  end

  private
  def filter(feed)
    projects = builds(feed)
    successful_builds = projects.select { |p| p.last_build_status == "Success"}
    broken_builds = projects.select { |p| p.last_build_status != "Success"}
    return successful_builds, broken_builds
  end
  
  def group(projects)
    sorted_projects = projects.sort_by(&:name)
    grouped_by_pipeline = sorted_projects.group_by do |project|
      project.name.split("::").first.strip
    end
    pipeline_with_stages(grouped_by_pipeline)
  end
end