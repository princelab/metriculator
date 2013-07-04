XTandem_executable_path = AppConfig[:xtandem_executable_path]
# integration points are [:on_db_store, :on_finish, :on_parse ]
Metriculator.integration( :on_finish) do |msrun|
  response = %x|#{XTandem_executable_path} #{msrun.rawfile}|  # %x| stuff | is almost equivalent to system "stuff" except it allows you to capture the output
  File.open ("xtandem_response.txt", "w") do |f|
    f.puts response
  end
  puts "Submitted #{msrun.rawfile} to XTandem... Read the response at xtandem_response.txt"
end
