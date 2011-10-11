require "rexml/document"
require 'net/https'
require 'uri'
require 'ostruct'
require 'base64'

class CCTray
  include CruiseControlAdapter
  
  def projects(feed)
    projects = []    
    parse(feed) { |element| projects << refine(element) }
    projects.reject! {|p| p.last_build_status == "Success"} if ONLY_BROKEN_BUILDS
    projects
  end

  def pipelines(feed)
    projects = projects(feed)
    sorted_projects = projects.sort_by(&:name)
    grouped_by_pipeline = sorted_projects.group_by do |project|
      project.name.split("::").first.strip
    end
    pipeline_with_stages(grouped_by_pipeline)
  end
  
  def filter(feed)
    all = pipelines(feed)
    all.select { |name, stages| PIPELINES.include? name }
  end
  
end