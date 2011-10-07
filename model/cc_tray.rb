require "rexml/document"
require 'net/https'
require 'uri'
require 'ostruct'
require 'base64'

class CCTray
  include CruiseControlAdapter
  
  def projects(feed)
    projects = []    
    parse(feed) do |element|
      projects << refine(element)
      projects.reject! {|p| p.last_build_status != "Success"} if ONLY_BROKEN_BUILDS
    end
    projects
  end

  def pipelines(feed)
    projects = projects(feed)
    sorted_projects = projects.sort_by(&:name)
    grouped_by_pipeline = sorted_projects.group_by do |project|
      project.name.split("::").first
    end
    pipeline_with_stages(grouped_by_pipeline)
  end
  
private

  def pipeline_with_stages(grouped_by_pipeline) 
    grouped_by_pipeline.each do |pipeline, stages|
      stages = stages.each {|stage| stage.name = stage.name.partition("::").last}
    end
  end
  def convert( project )
    values = {}
    project.attributes.each do |name, value|
      values.merge!( name.underscore.to_sym => value.to_s )
    end
    OpenStruct.new(values)
  end
  
  def refine(element)
    return convert(element) if NO_STATS || element.attributes['name'].include?("Could not connect")
    record(element)
  end
  
  def record(element)
    project = Project.find_or_create(element)
    project.record!(element)
    project
  end
  
end