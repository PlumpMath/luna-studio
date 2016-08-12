"use strict";

var $$       = require('common');

var vs = require('shaders/sdf.vert')();
var fs = require('shaders/node.frag')();
var userFs = require('shaders/node_user.frag')();

var unselectedColor    = new THREE.Color(0x3a3a3a);
var selectedColor      = new THREE.Color(0xb87410).multiplyScalar(0.8);
var errorColor         = new THREE.Color(0x651401);
var collaborationColor = new THREE.Color(0x45ffff);

var nodeGeometry    = new THREE.PlaneBufferGeometry(1.0, 1.0);
nodeGeometry.applyMatrix(new THREE.Matrix4().makeTranslation(0.5, 0.5, 0.0));


var nodeSize = 100.0;

function Node(position, z, widgetId) {
  var _this = this;

  this.position = position;

  this.uniforms = {
    selected:           { type: 'i',  value:                               0 },
    collaboration:      { type: 'i',  value:                               0 },
    mouseDist:          { type: 'f',  value:                             0.0 },
    expanded:           { type: 'f',  value:                             0.0 },
    size:               { type: 'v2', value:   new THREE.Vector2(nodeSize, nodeSize) },
    unselectedColor:    { type: 'c',  value:                 unselectedColor },
    selectedColor:      { type: 'c',  value:                   selectedColor },
    errorColor:         { type: 'c',  value:                      errorColor },
    collaborationColor: { type: 'c',  value:              collaborationColor },
    alpha:              { type: 'f',  value:                             1.0 },
    error:              { type: 'i',  value:                               0 },
    highlight:          { type: 'i',  value:                               0 },
    objectId:           { type: 'v3', value: new THREE.Vector3((widgetId % 256) / 255.0, Math.floor(Math.floor(widgetId % 65536) / 256) / 255.0, Math.floor(widgetId / 65536) / 255.0) }
  };

  Object.keys($$.commonUniforms).forEach(function (k) {
    _this.uniforms[k] = $$.commonUniforms[k];
  });

  this.mesh = new THREE.Group();
  this.node = new THREE.Mesh(
    nodeGeometry,
    new THREE.ShaderMaterial( {
      uniforms:       this.uniforms,
      vertexShader:   vs,
      fragmentShader: fs,
      transparent:    true,
      blending:       THREE.NormalBlending,
      side:           THREE.DoubleSide,
      derivatives:    true
    })
  );
  this.node.position.set(-nodeSize/2, -nodeSize/2, 0);

  this.expandedNode = new THREE.Group();
  this.container    = this.mesh;
  this.mesh.add(this.node);

  this.node.scale.x = nodeSize;
  this.node.scale.y = nodeSize;

  this.mesh.position.x = position.x;
  this.mesh.position.y = position.y;

  this.collaborationGroup = new THREE.Group();
  this.collaborationGroup.position.x = 30;
  this.collaborationGroup.position.y = -30;
  this.mesh.add(this.collaborationGroup);
}

Node.prototype.setPending = function () {
  this.uniforms.alpha.value = 0.2;
};

Node.prototype.setSelected = function (val) {
  this.uniforms.selected.value = val?1:0;
};
Node.prototype.setHighlight = function (val) {
  this.uniforms.highlight.value = val?1:0;
};
Node.prototype.setError = function (val) {
  this.uniforms.error.value = val?1:0;
};

Node.prototype.setCollaboration = function (val, users) {
  var _this = this;
  this.uniforms.collaboration.value = val;
  this.collaborationGroup.children.forEach(function(obj) {
    _this.collaborationGroup.remove(obj);
  });
  users.forEach(function(user, ix) {
    var uniforms = {
      colorId: { type: 'i',   value: user },
      size:    { type: 'v2',  value: new THREE.Vector2(14, 14)},
    };

    Object.keys($$.commonUniforms).forEach(function (k) {
      uniforms[k] = $$.commonUniforms[k];
    });

    var userMesh =  new THREE.Mesh(
      nodeGeometry,
      new THREE.ShaderMaterial( {
        uniforms:       uniforms,
        vertexShader:   vs,
        fragmentShader: userFs,
        transparent:    true,
        blending:       THREE.NormalBlending,
        side:           THREE.DoubleSide,
        derivatives:    true
      })
    );
    userMesh.position.x = 13*ix;
    userMesh.scale.x = 14;
    userMesh.scale.y = 14;
    _this.collaborationGroup.add(userMesh);
  });
};


Node.prototype.setZPos = function (z) {
  this.mesh.position.z = z;
};

Node.prototype.destructor = function () {};

Node.prototype.redrawTextures = function () {};
Node.prototype.widgetMoved    = function () {};

module.exports = Node;
