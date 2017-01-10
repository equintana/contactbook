
lib_root = __dir__
dependencies = ['jasperreports', 'commons-logging','commons-collections', 'commons-digester', 'com.lowagie.text']
dependencies.each do |dependency_name|
  Dir.entries("#{lib_root}/#{dependency_name}").each do |lib|
    require "#{lib_root}/#{dependency_name}/#{lib}" if lib =~ /\.jar$/
  end
end

require 'java'
require 'jdbc/sqlite3'

java_import Java::net::sf::jasperreports::engine::JasperFillManager
java_import Java::net::sf::jasperreports::engine::JasperExportManager
java_import Java::net::sf::jasperreports::engine::JRResultSetDataSource

class JasperReport

  LIB_ROOT = __dir__
  DIR = "#{LIB_ROOT}/../app/reports"

  def initialize(report, query, params = nil)
    @model = report
    @report_params = params

    Java::org.sqlite.JDBC
    url = 'jdbc:sqlite:/Users/erlinis/projects/contactbook/db/development.sqlite3'
    @conn = java.sql.DriverManager.getConnection(url)
    # @conn = ActiveRecord::Base.connection.jdbc_connection
    @query = query
  end

  def to_pdf
    stmt = @conn.create_statement
    @result = JRResultSetDataSource.new(stmt.execute_query(@query))
    report_source = "#{DIR}/#{@model}.jasper"
    raise ArgumentError, "#@model does not exist." unless File.exist?(report_source)
    params = {}
    params.merge!(@report_params) if @report_params.present?
    fill = JasperFillManager.fill_report(report_source, params, @result)
    pdf = JasperExportManager.export_report_to_pdf(fill)
    return String.from_java_bytes(pdf)
  end
end
