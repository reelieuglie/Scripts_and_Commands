## Resources:

### [Trivy](https://github.com/aquasecurity/trivy)
* Can run from container:
  * `docker run aquasec/trivy <target> [--scanners <scanner1,scanner2>] <subject>`
  * Example:
    * docker run aquasec/trivy image ubuntu
### [Syft](https://github.com/anchore/syft)/[Grype](https://github.com/anchore/grype)
 * Installation Steps:
   * **Note** Need a better way of install than curl piped through a shell
   * [Syft Installation](https://github.com/anchore/syft?tab=readme-ov-file#recommended)
   * [Grype Installatin](https://github.com/anchore/grype?tab=readme-ov-file#recommended)
