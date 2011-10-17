mongo_version("2.0.0")
mongo_name("mongodb-linux-#{@attribute["kernel"]["machine"]}-#{@attribute["mongo_version"]}")
mongo_path("/opt/mongodb-linux-#{@attribute["kernel"]["machine"]}-#{@attribute["mongo_version"]}")
mongo_base("/data/mongodb")
mongo_port("27017")
mongo_utility_instances( @attribute["utility_instances"].select { |ui| ui["name"].match(/mongodb/) } )
mongo_command("#{@attribute['mongo_path']}/bin/mongo")

if @attribute["utility_instances"].empty? || mongo_utility_instances.empty?
  # We have detected no utility instances, so we are skipping the logic for this portion of the recipe.
else
  # Chef::Log.info "mongo_utility_instances: #{@attribute["utility_instances"].inspect()}" 
  
  if mongo_utility_instances[0]["name"].match(/repl/)
    mongo_replset ( mongo_utility_instances[1]["name"].sub("mongodb_","").sub("repl","").split("_")[0] )
  else
    mongo_replset( false )
  end
  
  # detect backup node
  mongo_utility_instances.each do |mongo_node|   
    if mongo_node["name"].match(/_bkp/)
      Chef::Log.info "detected backup node #{mongo_node["name"]}"
       mongo_backup( true )
    else
      mongo_backup( false )
    end
  end  
 end
mongo_journaling ( true )
