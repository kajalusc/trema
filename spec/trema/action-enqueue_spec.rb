#
# Author: Nick Karanatsios <nickkaranatsios@gmail.com>
#
# Copyright (C) 2008-2011 NEC Corporation
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License, version 2, as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#


require File.join( File.dirname( __FILE__ ), "..", "spec_helper" )
require "trema"


describe Trema::ActionEnqueue, "A new enqueue action" do
  it "should be specified by its port and queue id attributes" do
    action_enqueue = Trema::ActionEnqueue.new( 1, 123 )
    action_enqueue.port.should == 1
    action_enqueue.queue_id.should == 123
  end


  it "should respond to #to_s and return a string" do
    action_enqueue = Trema::ActionEnqueue.new( 1, 123 )
    action_enqueue.should respond_to :to_s 
    action_enqueue.to_s.should == "#<Trema::ActionEnqueue> port = 1, queue_id = 123"
  end 
  
  
  it "appends its attributes to a list of actions" do
    action_enqueue = Trema::ActionEnqueue.new( 1, 123 )
    openflow_actions = double( )
    action_enqueue.should_receive( :append ).with( openflow_actions )
    action_enqueue.append( openflow_actions )
  end
  
  
  context "when sending #flow_mod(add) with action set to enqueue" do
    it "should have a flow with action set to enqueue" do
      class FlowModAddController < Controller; end
      network {
        vswitch { datapath_id 0xabc }
      }.run( FlowModAddController ) {
        controller( "FlowModAddController" ).send_flow_mod_add( 0xabc,
          :actions => ActionEnqueue.new( 1, 123 ) )
        switch( "0xabc" ).should have( 1 ).flows
        switch( "0xabc" ).flows[0].actions.should match( /enqueue:1q123/ )
      }
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End: