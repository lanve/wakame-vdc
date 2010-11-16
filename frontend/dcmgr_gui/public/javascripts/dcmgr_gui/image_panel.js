DcmgrGUI.prototype.imagePanel = function(){
  var total = 0;
  var maxrow = 10;
  var page = 1;
  var list_request = { 
    "url":DcmgrGUI.Util.getPagePath('/images/list/',page),
    "data" : DcmgrGUI.Util.getPagenateData(page,maxrow)
  }
  
  DcmgrGUI.List.prototype.getEmptyData = function(){
    return [{
      "id":'',
      "wmi_id":'',
      "source":'',
      "owner":'',
      "visibility":'',
      "state":''
    }]
  }
  
  DcmgrGUI.Detail.prototype.getEmptyData = function(){
        return {
            "name" : "-",
            "description" : "-",
            "source" : "-",
            "owner" : "-",
            "visibility" : "-",
            "product_code" : "-",
            "state" : "-",
            "karnel_id":"-",
            "platform" : "-",
            "root_device_type":"-",
            "root_device":"-",
            "image_size":"-",
            "block_devices":"-",
            "virtualization":"",
            "state_reason":"-"
          }
      }
  var c_pagenate = new DcmgrGUI.Pagenate({
    row:maxrow,
    total:total
  });
  
  var c_list = new DcmgrGUI.List({
    element_id:'#display_images',
    template_id:'#imagesListTemplate',
    maxrow:maxrow,
    page:page
  });
      
  c_list.setDetailTemplate({
    template_id:'#imagesDetailTemplate',
    detail_path:'/images/show/'
  });
  
  c_list.element.bind('dcmgrGUI.contentChange',function(event,params){
    var image = params.data.image;
    c_pagenate.changeTotal(image.owner_total);
    c_list.setData(image.results);
    c_list.singleCheckList(c_list.detail_template);
  });
  
  var bt_refresh  = new DcmgrGUI.Refresh();
  
  bt_refresh.element.bind('dcmgrGUI.refresh',function(){
    c_list.page = c_pagenate.current_page;
    list_request.url = DcmgrGUI.Util.getPagePath('/images/list/',c_pagenate.current_page);
    list_request.data = DcmgrGUI.Util.getPagenateData(c_pagenate.start,c_pagenate.row);
    c_list.element.trigger('dcmgrGUI.updateList',{request:list_request})
    
    //update detail
    $.each(c_list.checked_list,function(check_id,obj){
     
     //remove
     $($('#detail').find('#'+check_id)).remove();
     
     //update
     c_list.checked_list[check_id].c_detail.update({
       url:DcmgrGUI.Util.getPagePath('/images/show/',check_id)
     },true);
    });
  });
  
  c_pagenate.element.bind('dcmgrGUI.updatePagenate',function(){
    c_list.clearCheckedList();
    $('#detail').html('');
    bt_refresh.element.trigger('dcmgrGUI.refresh');
  });
  
  var bt_launch_instance = new DcmgrGUI.Dialog({
    target:'.launch_instance',
    width:583,
    height:600,
    title:'Launch Instance',
    path:'/launch_instance',
    callback: function(){
      
      var self = this;

      //get ssh key pairs
      $.ajax({
        "type": "GET",
        "async": true,
        "url": '/keypairs/all.json',
        "dataType": "json",
        "data": "",
        success: function(json,status){
          var results = json.ssh_key_pair.results;
          var size = results.length;
          var select_keypair = $(self).find('#ssh_key_pair');
          for (var i=0; i < size ; i++) {
            var name = results[i].result.name;
            var ssh_keypair_id = results[i].result.id;
            var html = '<option id="'+ ssh_keypair_id +'" value="'+ name +'">'+name+'</option>'
            select_keypair.append(html);
          }
        }
      });
        
      //get security groups
      $.ajax({
        "type": "GET",
        "async": true,
        "url": '/security_groups/all.json',
        "dataType": "json",
        "data": "",
        success: function(json,status){
          var data = [];
          var results = json.netfilter_group.results;
          var size = results.length
          for (var i=0; i < size ; i++) {
            data.push({
              "value" : results[i].result.uuid,
              "name" : results[i].result.name
            });
          }
          
          var security_group = new DcmgrGUI.ItemSelector({
            'left_select_id' : '#left_select_list',
            'right_select_id' : "#right_select_list",
            "data" : data
          });

          $(self).find('#right_button').click(function(){
            security_group.leftToRight();
          });

          $(self).find('#left_button').click(function(){
            security_group.rightToLeft();
          });
        }
      });
    },
    button:{
     "Launch": function() { 
       var image_id = $(this).find('#image_id').val();
       var host_pool_id = $(this).find('#host_pool_id').val();
       var host_name = $(this).find('#host_name').val();
       var instance_spec = $(this).find('#instance_spec').val();
       var ssh_key_pair = $(this).find('#ssh_key_pair').find('option:selected').text();
       var launch_in = $(this).find('#right_select_list').find('option');
       var user_data = $(this).find('#user_data').val();
       
       var nf_group = [];
       $.each(launch_in,function(i){
         nf_group.push("nf_group[]="+ $(this).text());
       });
       var nf_strings = nf_group.join('&');
       
       var data = "image_id="+image_id
                  +"&host_pool_id="+host_pool_id
                  +"&instance_spec_id="+instance_spec
                  +"&host_name="+host_name
                  +"&user_data="+user_data
                  +"&"+nf_strings
                  +"&ssh_key="+ssh_key_pair;
                  
        $.ajax({
          "type": "POST",
          "async": true,
          "url": '/instances',
          "dataType": "json",
          "data": data,
          success: function(json,status){
            bt_refresh.element.trigger('dcmgrGUI.refresh');
          }
        });
        
        $(this).dialog("close");
      }
    }
  });
  
  bt_launch_instance.target.bind('click',function(){
    var id = c_list.currentChecked();
    if( id ){
      bt_launch_instance.open({"ids":[id]});
    }
    return false;
  });

  //list
  c_list.setData(null);
  c_list.update(list_request,true);
}