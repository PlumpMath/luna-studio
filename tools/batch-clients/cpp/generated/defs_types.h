/**
 * Autogenerated by Thrift Compiler (0.9.0)
 *
 * DO NOT EDIT UNLESS YOU ARE SURE THAT YOU KNOW WHAT YOU ARE DOING
 *  @generated
 */
#ifndef defs_TYPES_H
#define defs_TYPES_H

#include <thrift/Thrift.h>
#include <thrift/TApplicationException.h>
#include <thrift/protocol/TProtocol.h>
#include <thrift/transport/TTransport.h>

#include "attrs_types.h"
#include "libs_types.h"
#include "types_types.h"


namespace flowbox { namespace batch { namespace defs {

typedef int32_t DefID;

typedef std::vector<class Import>  Imports;

typedef struct _Import__isset {
  _Import__isset() : path(false), items(false) {}
  bool path;
  bool items;
} _Import__isset;

class Import {
 public:

  static const char* ascii_fingerprint; // = "92AA23526EDCB0628C830C8758ED7059";
  static const uint8_t binary_fingerprint[16]; // = {0x92,0xAA,0x23,0x52,0x6E,0xDC,0xB0,0x62,0x8C,0x83,0x0C,0x87,0x58,0xED,0x70,0x59};

  Import() {
  }

  virtual ~Import() throw() {}

  std::vector<std::string>  path;
  std::vector<std::string>  items;

  _Import__isset __isset;

  void __set_path(const std::vector<std::string> & val) {
    path = val;
    __isset.path = true;
  }

  void __set_items(const std::vector<std::string> & val) {
    items = val;
    __isset.items = true;
  }

  bool operator == (const Import & rhs) const
  {
    if (__isset.path != rhs.__isset.path)
      return false;
    else if (__isset.path && !(path == rhs.path))
      return false;
    if (__isset.items != rhs.__isset.items)
      return false;
    else if (__isset.items && !(items == rhs.items))
      return false;
    return true;
  }
  bool operator != (const Import &rhs) const {
    return !(*this == rhs);
  }

  bool operator < (const Import & ) const;

  uint32_t read(::apache::thrift::protocol::TProtocol* iprot);
  uint32_t write(::apache::thrift::protocol::TProtocol* oprot) const;

};

void swap(Import &a, Import &b);

typedef struct _Definition__isset {
  _Definition__isset() : cls(false), imports(true), flags(true), attribs(true), defID(true) {}
  bool cls;
  bool imports;
  bool flags;
  bool attribs;
  bool defID;
} _Definition__isset;

class Definition {
 public:

  static const char* ascii_fingerprint; // = "37C5904B6456CFA1936B4DCB7E2E667D";
  static const uint8_t binary_fingerprint[16]; // = {0x37,0xC5,0x90,0x4B,0x64,0x56,0xCF,0xA1,0x93,0x6B,0x4D,0xCB,0x7E,0x2E,0x66,0x7D};

  Definition() : defID(-1) {



  }

  virtual ~Definition() throw() {}

   ::flowbox::batch::types::Type cls;
  Imports imports;
   ::flowbox::batch::attrs::Flags flags;
   ::flowbox::batch::attrs::Attributes attribs;
  DefID defID;

  _Definition__isset __isset;

  void __set_cls(const  ::flowbox::batch::types::Type& val) {
    cls = val;
    __isset.cls = true;
  }

  void __set_imports(const Imports& val) {
    imports = val;
    __isset.imports = true;
  }

  void __set_flags(const  ::flowbox::batch::attrs::Flags& val) {
    flags = val;
    __isset.flags = true;
  }

  void __set_attribs(const  ::flowbox::batch::attrs::Attributes& val) {
    attribs = val;
    __isset.attribs = true;
  }

  void __set_defID(const DefID val) {
    defID = val;
    __isset.defID = true;
  }

  bool operator == (const Definition & rhs) const
  {
    if (__isset.cls != rhs.__isset.cls)
      return false;
    else if (__isset.cls && !(cls == rhs.cls))
      return false;
    if (__isset.imports != rhs.__isset.imports)
      return false;
    else if (__isset.imports && !(imports == rhs.imports))
      return false;
    if (__isset.flags != rhs.__isset.flags)
      return false;
    else if (__isset.flags && !(flags == rhs.flags))
      return false;
    if (__isset.attribs != rhs.__isset.attribs)
      return false;
    else if (__isset.attribs && !(attribs == rhs.attribs))
      return false;
    if (__isset.defID != rhs.__isset.defID)
      return false;
    else if (__isset.defID && !(defID == rhs.defID))
      return false;
    return true;
  }
  bool operator != (const Definition &rhs) const {
    return !(*this == rhs);
  }

  bool operator < (const Definition & ) const;

  uint32_t read(::apache::thrift::protocol::TProtocol* iprot);
  uint32_t write(::apache::thrift::protocol::TProtocol* oprot) const;

};

void swap(Definition &a, Definition &b);

typedef struct _Edge__isset {
  _Edge__isset() : src(false), dst(false) {}
  bool src;
  bool dst;
} _Edge__isset;

class Edge {
 public:

  static const char* ascii_fingerprint; // = "C1241AF5AA92C586B664FD41DC97C576";
  static const uint8_t binary_fingerprint[16]; // = {0xC1,0x24,0x1A,0xF5,0xAA,0x92,0xC5,0x86,0xB6,0x64,0xFD,0x41,0xDC,0x97,0xC5,0x76};

  Edge() : src(0), dst(0) {
  }

  virtual ~Edge() throw() {}

  DefID src;
  DefID dst;

  _Edge__isset __isset;

  void __set_src(const DefID val) {
    src = val;
    __isset.src = true;
  }

  void __set_dst(const DefID val) {
    dst = val;
    __isset.dst = true;
  }

  bool operator == (const Edge & rhs) const
  {
    if (__isset.src != rhs.__isset.src)
      return false;
    else if (__isset.src && !(src == rhs.src))
      return false;
    if (__isset.dst != rhs.__isset.dst)
      return false;
    else if (__isset.dst && !(dst == rhs.dst))
      return false;
    return true;
  }
  bool operator != (const Edge &rhs) const {
    return !(*this == rhs);
  }

  bool operator < (const Edge & ) const;

  uint32_t read(::apache::thrift::protocol::TProtocol* iprot);
  uint32_t write(::apache::thrift::protocol::TProtocol* oprot) const;

};

void swap(Edge &a, Edge &b);

typedef struct _DefsGraph__isset {
  _DefsGraph__isset() : defs(false), edges(false) {}
  bool defs;
  bool edges;
} _DefsGraph__isset;

class DefsGraph {
 public:

  static const char* ascii_fingerprint; // = "635C3E7C30A40F02DDADB144E29783F6";
  static const uint8_t binary_fingerprint[16]; // = {0x63,0x5C,0x3E,0x7C,0x30,0xA4,0x0F,0x02,0xDD,0xAD,0xB1,0x44,0xE2,0x97,0x83,0xF6};

  DefsGraph() {
  }

  virtual ~DefsGraph() throw() {}

  std::map<DefID, Definition>  defs;
  std::vector<Edge>  edges;

  _DefsGraph__isset __isset;

  void __set_defs(const std::map<DefID, Definition> & val) {
    defs = val;
    __isset.defs = true;
  }

  void __set_edges(const std::vector<Edge> & val) {
    edges = val;
    __isset.edges = true;
  }

  bool operator == (const DefsGraph & rhs) const
  {
    if (__isset.defs != rhs.__isset.defs)
      return false;
    else if (__isset.defs && !(defs == rhs.defs))
      return false;
    if (__isset.edges != rhs.__isset.edges)
      return false;
    else if (__isset.edges && !(edges == rhs.edges))
      return false;
    return true;
  }
  bool operator != (const DefsGraph &rhs) const {
    return !(*this == rhs);
  }

  bool operator < (const DefsGraph & ) const;

  uint32_t read(::apache::thrift::protocol::TProtocol* iprot);
  uint32_t write(::apache::thrift::protocol::TProtocol* oprot) const;

};

void swap(DefsGraph &a, DefsGraph &b);

}}} // namespace

#endif
