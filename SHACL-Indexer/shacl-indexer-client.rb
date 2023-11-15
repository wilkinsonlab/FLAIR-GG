# curl -X 'GET' \
#   'http://138.4.139.18:9090/index/entries?page=0&size=1&sort=string' \
#   -H 'accept: application/json'
# {"content":[{"uuid":"5c586201-44c6-4161-8641-3947d2cb3656","clientUrl":"https://w3id.org/bgv-fdp","state":"ACTIVE","registrationTime":"2023-07-24T12:04:50.374Z","modificationTime":"2023-11-03T09:04:25.638Z"}],"pageable":{"sort":{"empty":false,"unsorted":false,"sorted":true},"offset":0,"pageNumber":0,"pageSize":1,"paged":true,"unpaged":false},"totalPages":1,"totalElements":1,"last":true,"size":1,"number":0,"sort":{"empty":false,"unsorted":false,"sorted":true},"numberOfElements":1,"first":true,"empty":false}

require_relative "utils"

fdps = get_fdps  # call to FDP index

fdps.each do |fdp|
  token = get_token fdp: fdp
  catalogs = get_catalogs(fdp: fdp, token: token)
  warn catalogs
  catalogs.each do |cat|
    dsets = get_datasets(cat: cat, token: token)
    warn dsets
    dsets.each do |dset|
      dists = get_distributions(dset: dset, token: token)
      warn dists
      dists.each do |dist|
        servs = get_data_services(dist: dist, token: token)
        warn servs
        servs.each do |serv|
          sparql_endpoints = get_sparql_endpoints(serv: serv)
          sparql_endpoints.each do |dset, endpoint|
            puts "#{dset} : #{endpoint}"
            resp = RestClient.post('http://138.4.139.18:6000/index/', "{\"url\": \"#{endpoint}\"}")
            shacl = resp.body
            puts shacl  
            write_to_repo(shacl: shacl, dataset: dset, catalog: cat, endpoint: endpoint)
          end
        end
      end
    end
  end
end

