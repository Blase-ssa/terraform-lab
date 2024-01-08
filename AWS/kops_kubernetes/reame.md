This script does not work due to an error in "kOps".

I saved it as a sample.


kOps version: 1.28.2 (git-v1.28.2)

Error:
` error finding instance info for instance type "strings=t3.micro": describing instance type
 "strings=t3.micro" in region "eu-north-": MissingEndpoint: 'Endpoint' configuration is required for this service`

The number "1" always disappears from the region name. Perhaps the same thing happens with other numbers.
A possible solution is to use a YAML file with settings, but at the moment I have no task to solve this problem.