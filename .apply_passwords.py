# open .passwords and apply the passwords to yaml manifests.

# make sure that all env var password keys in the .passwords files are unique or else raise.
# track and report entries in .passwords that do not get found in manifests.
# track and report entries in manifests that do not have dropins in .passwords
