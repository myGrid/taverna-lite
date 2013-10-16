# Copyright (c) 2012-2013 Cardiff University, UK.
# Copyright (c) 2012-2013 The University of Manchester, UK.
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the names of The University of Manchester nor Cardiff University nor
#   the names of its contributors may be used to endorse or promote products
#   derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
# Authors
#     Abraham Nieva de la Hidalga
#
# Synopsis
#
# BioVeL Taverna Lite is a prototype interface provided to support the
# inspection and modification of workflows.
#
# For more details see http://www.biovel.eu
#
# BioVeL is funded by the European Commission 7th Framework Programme (FP7),
# through the grant agreement number 283359.
require 'test_helper'

module TavernaLite
  class T2flowWriterTest < ActiveSupport::TestCase
    setup do
      # need a set up with the value of the workflow file path copy the file so
      # that it can be used in different tests
      # using  HelloAnyone Workflow for testing workflow annotation
      @fixture_path = ActiveSupport::TestCase.fixture_path
      from_here = @fixture_path+'/test_workflows/HelloAnyone.t2flow'
      to_there = @fixture_path+'/test_workflows/test_result/HelloAnyone.t2flow'
      FileUtils.cp from_here, to_there
      @workflow_file_path = to_there
    end
    test "should update_workflow_annotations" do
      author = "Stian Soiland Reyes"
      description = "Extension to helloworld.t2flow\n\t The workflow takes a input \'name\' called which is combined with the string constant 'Hello'\n\t A local worker processor called 'Concatenate two strings' is used.\n\t The output is the concatenated string 'greeting'"
      name =  "Hello_Anyone"
      title = "Hello Anyone"
      # modify the t2flow file by writing annotations
      writer = T2flowWriter.new
      writer.save_wf_annotations(@workflow_file_path , author, description, title, name)
      # verify that the file is t2flow
      file_data = File.open(@workflow_file_path)
      model = T2Flow::Parser.new.parse(file_data)
      assert_not_equal(model, nil)
      # verify that the file annotaions are the same as those passed as
      # parameters
      m_name = model.name
      m_author = model.annotations.authors[0].to_s
      m_title = model.annotations.titles[0].to_s
      m_description = model.annotations.descriptions[0].to_s
      assert_equal(m_name,name)
      assert_equal(m_author, author)
      assert_equal(m_title, title)
      assert_equal(m_description,  ERB::Util.html_escape(description))
    end
    test "should_uptate_input_annotations" do
      port_name = "name"
      new_name = "name"
      description = "The name that will be concatenated with the 'Hello ' string"
      example_val= "Wonderful World!"
      # modify the t2flow file by writing annotations
      writer = T2flowWriter.new
      writer.save_wf_port_annotations(@workflow_file_path , port_name, new_name, description, example_val,1)
      # verify that the file is t2flow
      file_data = File.open(@workflow_file_path)
      # verify that the file is t2flow
      model = T2Flow::Parser.new.parse(file_data)
      assert_not_equal(model, nil)
      # verify that the file annotaions are the same as those passed as
      # parameters
      #get the input port name description and example values
      port_name = ""
      port_example = ""
      port_description = ""
      model.sources.each do |source|
        port_name = source.name
        port_example = source.example_values[0]
        port_description = source.descriptions[0]
      end
      assert_equal(port_example,example_val)
      assert_equal(port_description,ERB::Util.html_escape(description))
    end
    # Pending test changing the name to the port, not trivial needs some work
    # need to also replace all refernces to the port for instance in datalinks
    test "should_uptate_input_name" do
      port_name = "name"
      new_name = "greeting_name"
      description = "The name that will be concatenated with the 'Hello ' string"
      example_val= "Wonderful World!"
      # modify the t2flow file by writing annotations
      writer = T2flowWriter.new
      writer.save_wf_port_annotations(@workflow_file_path , port_name, new_name, description, example_val,1)
      # verify that the file is t2flow
      file_data = File.open(@workflow_file_path)
      # verify that the file is t2flow
      model = T2Flow::Parser.new.parse(file_data)
      assert_not_equal(model, nil)
      # verify that the file annotaions are the same as those passed as
      # parameters
      #get the input port name and verify it was changed
      in_file_name = ""
      model.sources.each do |source|
        in_file_name = source.name
      end
      assert_equal(in_file_name,new_name)
      # get the datalinks and verify they have been updated
      found = ""
      model.datalinks.each do |dl|
        if dl.source == new_name
          found = dl.source
        end
      end
      assert_equal(found, new_name)
      # just to be safe, check that no datalinks referencing old name exist
      found = ""
      model.datalinks.each do |dl|
        if dl.source == port_name
          found = dl.source
        end
      end
      assert_equal(found, "")
    end
    test "should_uptate_output_annotations" do
      port_name = "greeting"
      new_name = "greeting"
      description = "The resulting greeting message 'Hello + Name'"
      example_val= "Hello Wonderful World!"
      # modify the t2flow file by writing annotations
      writer = T2flowWriter.new
      writer.save_wf_port_annotations(@workflow_file_path , port_name, new_name, description, example_val,2)
      # verify that the file is t2flow
      file_data = File.open(@workflow_file_path)
      # verify that the file is t2flow
      model = T2Flow::Parser.new.parse(file_data)
      assert_not_equal(model, nil)
      # verify that the file annotaions are the same as those passed as
      # parameters
      #get the output port name description and example values
      port_name = ""
      port_example = ""
      port_description = ""
      model.sinks.each do |sink|
        port_name = sink.name
        port_example = sink.example_values[0]
        port_description = sink.descriptions[0]
      end
      assert_equal(port_example,example_val)
      assert_equal(port_description,ERB::Util.html_escape(description))
    end
    # Pending test changing the name to the port, not trivial needs some work
    # need to also replace all refernces to the port for instance in datalinks
    test "should_uptate_output_name" do
      port_name = "greeting"
      new_name = "greeting_message"
      description = "The resulting greeting message 'Hello + Name'"
      example_val= "Hello Wonderful World!"
      # modify the t2flow file by writing annotations
      writer = T2flowWriter.new
      writer.save_wf_port_annotations(@workflow_file_path , port_name, new_name, description, example_val,2)
      # verify that the file is t2flow
      file_data = File.open(@workflow_file_path)
      # verify that the file is t2flow
      model = T2Flow::Parser.new.parse(file_data)
      assert_not_equal(model, nil)
      # verify that the file annotaions are the same as those passed as
      # parameters
      # get the input port name and verify it was changed
      port_name = ""
      model.sinks.each do |sink|
        port_name = sink.name
      end
      assert_equal(port_name,new_name)
      # get the datalinks and verify they have been updated
      found = ""
      model.datalinks.each do |dl|
        if dl.sink == new_name
          found = dl.sink
        end
      end
      assert_equal(found, new_name)
    end
    # Pending test of swap component
  end
end