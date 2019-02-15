module RubyJmeter
  class DSL
    def view_results_in_4_graph(params={}, &block)
      node = RubyJmeter::ViewResultsInResponseTimesPercentilesGui.new(params)
      attach_node(node, &block)
    end
  end

  class ViewResultsInResponseTimesPercentilesGui
    attr_accessor :doc
    include Helper

    def initialize(params={})
      testname = params.kind_of?(Array) ? 'ViewResultsInTable' : (params[:name] || 'ViewResultsInTable')
      @doc = Nokogiri::XML(<<-EOS.strip_heredoc)
        <kg.apc.jmeter.vizualizers.CorrectedResultCollector guiclass="kg.apc.jmeter.vizualizers.ResponseTimesPercentilesGui" testclass="kg.apc.jmeter.vizualizers.CorrectedResultCollector" testname="jp@gc - Response Times Percentiles" enabled="true">
          <boolProp name="ResultCollector.error_logging">false</boolProp>
          <objProp>
            <name>saveConfig</name>
            <value class="SampleSaveConfiguration">
              <time>true</time>
              <latency>true</latency>
              <timestamp>true</timestamp>
              <success>true</success>
              <label>true</label>
              <code>true</code>
              <message>true</message>
              <threadName>true</threadName>
              <dataType>true</dataType>
              <encoding>false</encoding>
              <assertions>true</assertions>
              <subresults>true</subresults>
              <responseData>false</responseData>
              <samplerData>false</samplerData>
              <xml>false</xml>
              <fieldNames>true</fieldNames>
              <responseHeaders>false</responseHeaders>
              <requestHeaders>false</requestHeaders>
              <responseDataOnError>false</responseDataOnError>
              <saveAssertionResultsFailureMessage>true</saveAssertionResultsFailureMessage>
              <assertionsResultsToSave>0</assertionsResultsToSave>
              <bytes>true</bytes>
              <sentBytes>true</sentBytes>
              <threadCounts>true</threadCounts>
              <idleTime>true</idleTime>
              <connectTime>true</connectTime>
            </value>
          </objProp>
          <stringProp name="filename"></stringProp>
          <longProp name="interval_grouping">500</longProp>
          <boolProp name="graph_aggregated">false</boolProp>
          <stringProp name="include_sample_labels"></stringProp>
          <stringProp name="exclude_sample_labels"></stringProp>
          <stringProp name="start_offset"></stringProp>
          <stringProp name="end_offset"></stringProp>
          <boolProp name="include_checkbox_state">false</boolProp>
          <boolProp name="exclude_checkbox_state">false</boolProp>
        </kg.apc.jmeter.vizualizers.CorrectedResultCollector>)
      EOS
      update params
      update_at_xpath params if params.is_a?(Hash) && params[:update_at_xpath]
    end
  end

end
