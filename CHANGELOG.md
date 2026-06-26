# Changelog

## [1.1.3](https://github.com/FelipeFuhr/ffreis-workflows-terraform/compare/v1.1.2...v1.1.3) (2026-06-22)


### Bug Fixes

* **ci:** restore uses: indentation + hash-verify checkov install ([#63](https://github.com/FelipeFuhr/ffreis-workflows-terraform/issues/63)) ([dbf2c48](https://github.com/FelipeFuhr/ffreis-workflows-terraform/commit/dbf2c48039866dbb054d9cdd691fbe270c1211c0))

## [1.1.2](https://github.com/FelipeFuhr/ffreis-workflows-terraform/compare/v1.1.1...v1.1.2) (2026-06-15)


### Bug Fixes

* **grype:** bump workflows-general SHA to prevent self-scan CVEs ([#50](https://github.com/FelipeFuhr/ffreis-workflows-terraform/issues/50)) ([5553d05](https://github.com/FelipeFuhr/ffreis-workflows-terraform/commit/5553d05bf3ae6a5655a275107be37183771c5b55))
* resolve SonarQube issues ([#53](https://github.com/FelipeFuhr/ffreis-workflows-terraform/issues/53)) ([6867fad](https://github.com/FelipeFuhr/ffreis-workflows-terraform/commit/6867fad38f25e4db9dc4d5cd0f19c99a96bb719a))
* **tf-docs:** fail drift check on modules missing a committed README ([#44](https://github.com/FelipeFuhr/ffreis-workflows-terraform/issues/44)) ([0afe17e](https://github.com/FelipeFuhr/ffreis-workflows-terraform/commit/0afe17e8e6bf217cb78280462b6187050476324f))

## [1.1.1](https://github.com/FelipeFuhr/ffreis-workflows-terraform/compare/v1.1.0...v1.1.1) (2026-05-24)


### Bug Fixes

* **ci:** drop misplaced timeout-minutes from pull_request trigger ([#37](https://github.com/FelipeFuhr/ffreis-workflows-terraform/issues/37)) ([2d19e43](https://github.com/FelipeFuhr/ffreis-workflows-terraform/commit/2d19e43ba77694bbe17c4cff3efd41e7baf52852))

## [1.1.0](https://github.com/FelipeFuhr/ffreis-workflows-terraform/compare/v1.0.0...v1.1.0) (2026-05-21)


### Features

* migrate to platform standards ([#34](https://github.com/FelipeFuhr/ffreis-workflows-terraform/issues/34)) ([31553f7](https://github.com/FelipeFuhr/ffreis-workflows-terraform/commit/31553f79a82aeb57b1bea533f322014ccb449eb2))

## 1.0.0 (2026-05-06)


### Features

* add more improvements ([f882d5a](https://github.com/FelipeFuhr/ffreis-workflows-terraform/commit/f882d5a21a187aa1c125d965b735f989c565ae15))
* ci improvements ([e0cd543](https://github.com/FelipeFuhr/ffreis-workflows-terraform/commit/e0cd54322d52fe7c522dd0bc2c46d56df2ceae43))
* **deps:** migrate to ffreis-platform-standards ([#31](https://github.com/FelipeFuhr/ffreis-workflows-terraform/issues/31)) ([95b4b16](https://github.com/FelipeFuhr/ffreis-workflows-terraform/commit/95b4b16ccfabafb7642fd8c27c107ea03f0987fa))
* general improvements ([1a7f279](https://github.com/FelipeFuhr/ffreis-workflows-terraform/commit/1a7f27978c7dd60a77db3ebd457074741e5573bb))
* general improvements ([bd3c7c4](https://github.com/FelipeFuhr/ffreis-workflows-terraform/commit/bd3c7c46c810a8b838dc5329702141330d3f4d15))
* migrate to ffreis-platform-standards and pin all action SHAs ([#30](https://github.com/FelipeFuhr/ffreis-workflows-terraform/issues/30)) ([1b59a92](https://github.com/FelipeFuhr/ffreis-workflows-terraform/commit/1b59a920b1b4b226f3e5a91eb9042827b9c435cb))
* more workflows ([9c3946a](https://github.com/FelipeFuhr/ffreis-workflows-terraform/commit/9c3946a34756efa4bd730bebd32d0e13aa867bbf))
* more workflows ([87905bf](https://github.com/FelipeFuhr/ffreis-workflows-terraform/commit/87905bf7f99a8752f0c4c72e2bf1c309004635a2))
* setup workflow ([57591ab](https://github.com/FelipeFuhr/ffreis-workflows-terraform/commit/57591ab14b77a817678f7015590f0fd2a309c2da))
* setup workflows ([79508ca](https://github.com/FelipeFuhr/ffreis-workflows-terraform/commit/79508caeed6b4a0c59ac7547df8799e8e47855f1))


### Bug Fixes

* actionlint + bump workflows-general v0.1.1 ([28b7a98](https://github.com/FelipeFuhr/ffreis-workflows-terraform/commit/28b7a98b4a29b743ec6b75c68c3c34ec584b5413))
* address PR review — concurrency isolation, AGENTS.md accuracy, github-script version ([c12c05d](https://github.com/FelipeFuhr/ffreis-workflows-terraform/commit/c12c05d2a45a3db9b9458e4e6f3df2d917925c68))
* address review comments - concurrency group, AGENTS.md rules, github-script version ([bccef6f](https://github.com/FelipeFuhr/ffreis-workflows-terraform/commit/bccef6f5d2c5615c005bf187aa019a20126f811a))
* address review feedback - quoting, checksum verification, and other fixes ([64001eb](https://github.com/FelipeFuhr/ffreis-workflows-terraform/commit/64001eb8851ba0c0924499e68ec12120b532b8f7))
* ci ([f71c5df](https://github.com/FelipeFuhr/ffreis-workflows-terraform/commit/f71c5df4cbd143b0f78ef044408be2a64072a568))
* ci ([#27](https://github.com/FelipeFuhr/ffreis-workflows-terraform/issues/27)) ([b358a2e](https://github.com/FelipeFuhr/ffreis-workflows-terraform/commit/b358a2e46807e58b4bb138e22a236cc93884c135))
* ci fixes ([271a3bb](https://github.com/FelipeFuhr/ffreis-workflows-terraform/commit/271a3bb51af66387c9cc9ad61e1f41c1bf56d799))
* ci fixes ([27cfd32](https://github.com/FelipeFuhr/ffreis-workflows-terraform/commit/27cfd3208d91aaa2ed0a727e4cece30f4d1b8465))
* don't cancel labeler runs ([eb94b07](https://github.com/FelipeFuhr/ffreis-workflows-terraform/commit/eb94b075b0846e70f2f3191c7ab0c87f5d869b15))
* fix trivy ([f8371d1](https://github.com/FelipeFuhr/ffreis-workflows-terraform/commit/f8371d1efb1d5417229864ad127a1e1d4a5b98aa))
* harden reusable workflows and developer tooling against injection and reliability issues ([ab022d5](https://github.com/FelipeFuhr/ffreis-workflows-terraform/commit/ab022d5120d3f89aecd409d563a7df1d8c4fcad6))
* self-test aws workflows in dry-run ([7b99ee6](https://github.com/FelipeFuhr/ffreis-workflows-terraform/commit/7b99ee6f764e2db0ff01dd856dbf0a86743dbfdc))
* sonar defaults and fork gating ([d0a8bf7](https://github.com/FelipeFuhr/ffreis-workflows-terraform/commit/d0a8bf726a887569ff78ce2ab84745dc86cd187e))
