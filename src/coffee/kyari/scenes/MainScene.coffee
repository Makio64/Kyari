class MainScene extends Scene

	constructor:()->

		@time = 0

		@container = new THREE.Object3D();
		@container.position.y -= 10;
		Stage3d.add(@container)

		@ambientLight = new THREE.AmbientLight(0x222222)
		Stage3d.add(@ambientLight)
		@cameraLight = new THREE.PointLight(0xffffff, 1, 400)
		@cameraLight.position.set( 30, 50, 50 );
		Stage3d.add(@cameraLight)

		loader = new THREE.JSONLoader()
		loader.load( './3d/json/baseHD.js', @onBaseLoad )

		loader = new THREE.JSONLoader()
		loader.load( './3d/json/diamond.js', @onDiamondLoad )

		loader = new THREE.JSONLoader()
		loader.load( './3d/json/crystal.js', @onCrystalLoad )

		loader = new THREE.JSONLoader()
		loader.load( './3d/json/waterHD.js', @onWaterLoad )

		loader = new THREE.JSONLoader()
		loader.load( './3d/json/face.js', @onFaceLoad )

		loader = new THREE.SceneLoader()
		loader.load( './3d/json/eye.js', @onEyeLoad )

		loader = new THREE.SceneLoader()
		loader.load( './3d/json/wheels.js', @onWheelsLoad )
		return

	onDiamondLoad:(geometry)=>
		@computeGeometry(geometry)
		material = new THREE.MeshBasicMaterial({color: 0xffffff})
		@diamond = new THREE.Mesh(geometry,material)
		@container.add(@diamond)
		return

	onFaceLoad:(geometry)=>
		@computeGeometry(geometry)
		material = new THREE.MeshBasicMaterial({color: 0xffffff, wireframe:true})
		@face = new THREE.Mesh(geometry,material)
		@container.add(@face)
		return

	onEyeLoad:(scene)=>

		shader = THREE.ShaderLib["normalmap"]
		@uniforms = THREE.UniformsUtils.clone(shader.uniforms)
		@uniforms["tNormal"].value = THREE.ImageUtils.loadTexture("./3d/textures/HD/NMAP_eye.png")
		@uniforms["tSpecular"].value = THREE.ImageUtils.loadTexture("./3d/textures/HD/DISP_eye.png")
		@uniforms["tDiffuse"].value = THREE.ImageUtils.loadTexture("./3d/textures/HD/TEXT_eye.png")
		@uniforms["enableDiffuse"].value = 1
		@uniforms["enableSpecular"].value = 1
		@uniforms["uNormalScale"].value.x = 2
		@uniforms["uNormalScale"].value.y = 2

		material = new THREE.ShaderMaterial({
			fragmentShader: shader.fragmentShader,
			vertexShader: shader.vertexShader,
			uniforms: @uniforms,
			lights: true,
			transparent: false,
			fog: false,
			color: 0xffffff
		})
		for k, v of scene.objects
			o = v
			if(o.name=='paupiereDown_Uv') then @closeDown =  o;
			else if(o.name=='paupiereUp_Uv') then @closeUp = o;
			else @eye = o;
			@computeGeometry(o.geometry)
			o.material = material
			@container.add(o)
		return

	onBaseLoad:(geometry)=>

		@computeGeometry(geometry)

		shader = THREE.ShaderLib["normalmap"]
		@uniforms = THREE.UniformsUtils.clone(shader.uniforms)
		@uniforms["tNormal"].value = THREE.ImageUtils.loadTexture("./3d/textures/HD/normalBase2048.png")
		@uniforms["tSpecular"].value = THREE.ImageUtils.loadTexture("./3d/textures/HD/specularBase2048.png")
		@uniforms["tDiffuse"].value = THREE.ImageUtils.loadTexture("./3d/textures/HD/base1024.png")
		@uniforms["enableDiffuse"].value = 1
		@uniforms["enableSpecular"].value = 1
		@uniforms["uNormalScale"].value.x = 2
		@uniforms["uNormalScale"].value.y = 2

		material = new THREE.ShaderMaterial({
			fragmentShader: shader.fragmentShader,
			vertexShader: shader.vertexShader,
			uniforms: @uniforms,
			lights: true,
			transparent: false,
			fog: false,
			color: 0xffffff
		})

		@mesh = new THREE.Mesh(geometry,material)
		@container.add(@mesh)
		return

	onCrystalLoad:(geometry)=>

		@computeGeometry(geometry)

		@crystalUniforms = {
			"tDiffuse": { type: "t", value: THREE.ImageUtils.loadTexture("./3d/textures/HD/crystal.jpg") },
			"uGlobalTime" : { type: "f", value: 0.0 }
			"uOpacity" : { type: "f", value: .5 }
		}

		material = new THREE.ShaderMaterial({

			fragmentShader:  [
				"uniform sampler2D tDiffuse;",
				"uniform float uGlobalTime;",
				"uniform float uOpacity;",
				"varying vec2 vUv;",
				"varying vec3 vPos;",

				"void main() {",
					"float ratio = vPos.x - .5;",
					"vec4 texture = texture2D( tDiffuse, vUv +cos(ratio-uGlobalTime*.04)*.4);",
					"float color = cos(ratio-uGlobalTime*.04)*.5;",
					"gl_FragColor = vec4( texture.rgb + color, uOpacity);",
				"}"
			].join("\n")

			vertexShader: [
				"uniform float uGlobalTime;",
				"varying vec2 vUv;",
				"varying vec3 vPos;",

				"void main() {",
					"vPos = position;",
					"vUv = uv;",
					"gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );",
				"}"
				].join('\n'),

			uniforms: @crystalUniforms,
			lights: false,
			transparent: true,
			fog: false,
			color: 0xffffff
		})

		@crystal = new THREE.Mesh(geometry,material)
		@container.add(@crystal)
		return

	onWaterLoad:(geometry)=>

		@computeGeometry(geometry)

		@waterUniforms = {
			"tDiffuse": { type: "t", value: THREE.ImageUtils.loadTexture("./3d/textures/HD/water.jpg") },
			"uGlobalTime" : { type: "f", value: 0.0 }
			"amplitude": { type: "f", value: .8 },
		}

		material = new THREE.ShaderMaterial({

			fragmentShader:  [
				"uniform sampler2D tDiffuse;",
				"uniform float uGlobalTime;",

				"varying vec2 vUv;",
				"varying vec3 vPos;",

				"void main() {",
					"float ratio = -vPos.y;",
					"float alpha = min(vPos.y/5.0,.15);",
					"vec4 texture = texture2D( tDiffuse, vUv +cos(ratio-uGlobalTime*.01)*.3);",
					"float color = cos(ratio-uGlobalTime*.04)*.35;",
					"gl_FragColor = vec4( texture.rgb + color, alpha);",
				"}"
			].join("\n")

			vertexShader: [
				"uniform float uGlobalTime;",
				"uniform float amplitude;",

				"varying vec3 vNormal;",
				"varying vec2 vUv;",
				"varying vec3 vPos;",

				"void main() {",
					"vNormal = normal;",
					"vUv = uv;",
					"vec3 newPosition = position + normal * vec3(cos(uGlobalTime/70.0+position.y*.4) * amplitude);",
					"vPos = newPosition;",
					"gl_Position = projectionMatrix * modelViewMatrix * vec4( newPosition, 1.0 );",
				"}"
				].join('\n'),

			uniforms: @waterUniforms,
			lights: false,
			transparent: true,
			fog: false,
			color: 0xffffff
		})

		@water = new THREE.Mesh(geometry,material)
		@container.add(@water)
		return

	onWheelsLoad:(scene)=>

		shader = THREE.ShaderLib["normalmap"]
		@uniforms = THREE.UniformsUtils.clone(shader.uniforms)
		@uniforms["tNormal"].value = THREE.ImageUtils.loadTexture("./3d/textures/HD/130331_NMAP_roues2048.png")
		@uniforms["tSpecular"].value = THREE.ImageUtils.loadTexture("./3d/textures/HD/130331_DISP_roues2048.png")
		@uniforms["tDiffuse"].value = THREE.ImageUtils.loadTexture("./3d/textures/HD/130331_TEXT_roues2048_002.png")
		@uniforms["enableDiffuse"].value = 1
		@uniforms["enableSpecular"].value = 1
		# @uniforms["uNormalScale"].value.x = 2
		# @uniforms["uNormalScale"].value.y = 2

		material = new THREE.ShaderMaterial({
			fragmentShader: shader.fragmentShader,
			vertexShader: shader.vertexShader,
			uniforms: @uniforms,
			lights: true,
			transparent: false,
			fog: false,
			color: 0xffffff
		})

		@wheelsVertical = []
		@wheelsHorizontal = []

		for k, v of scene.objects
			o = v
			@computeGeometry(o.geometry)

			# material = new THREE.MeshBasicMaterial()
			o.material = material
			@container.add(o)
			if (/_y_/i).test(k)
				@wheelsVertical.push(o)
			else
				@wheelsHorizontal.push(o)

		return

	computeGeometry:(geometry)->
		# compute the model
		geometry.computeBoundingSphere()
		geometry.computeFaceNormals()
		geometry.computeVertexNormals()
		geometry.computeTangents()
		geometry.computeMorphNormals()
		geometry.verticesNeedUpdate = true
		geometry.normalsNeedUpdate = true
		return


	update:(dt)->
		@time += dt
		@container.rotation.y += 0.005
		if @wheelsVertical
			for w in @wheelsVertical
				w.rotation.y += 0.003
			for w in @wheelsHorizontal
				w.rotation.x += 0.003
		if @closeDown
			@closeDown.rotation.x = Math.abs(Math.sin(@time/1000)*.7)
			@closeUp.rotation.x = -Math.abs(Math.sin(@time/1000)*.7)

		if(@crystalUniforms)
			@crystalUniforms["uGlobalTime"].value += dt/30
		if(@waterUniforms)
			@waterUniforms["uGlobalTime"].value += dt/30


		return
