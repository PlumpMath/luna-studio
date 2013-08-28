// This autogenerated skeleton file illustrates how to build a server.
// You should copy it to another filename to avoid overwriting it.

#include "Batch.h"
#include <thrift/protocol/TBinaryProtocol.h>
#include <thrift/server/TSimpleServer.h>
#include <thrift/transport/TServerSocket.h>
#include <thrift/transport/TBufferTransports.h>

using namespace ::apache::thrift;
using namespace ::apache::thrift::protocol;
using namespace ::apache::thrift::transport;
using namespace ::apache::thrift::server;

using boost::shared_ptr;

using namespace  ::flowbox::batch;

class BatchHandler : virtual public BatchIf {
 public:
  BatchHandler() {
    // Your initialization goes here
  }

  void projects(std::vector< ::flowbox::batch::projects::Project> & _return) {
    // Your implementation goes here
    printf("projects\n");
  }

  void createProject( ::flowbox::batch::projects::Project& _return, const  ::flowbox::batch::projects::Project& project) {
    // Your implementation goes here
    printf("createProject\n");
  }

  void openProject( ::flowbox::batch::projects::Project& _return, const std::string& path) {
    // Your implementation goes here
    printf("openProject\n");
  }

  void closeProject(const  ::flowbox::batch::projects::ProjectID projectID) {
    // Your implementation goes here
    printf("closeProject\n");
  }

  void storeProject(const  ::flowbox::batch::projects::ProjectID projectID) {
    // Your implementation goes here
    printf("storeProject\n");
  }

  void libraries(std::vector< ::flowbox::batch::libs::Library> & _return, const  ::flowbox::batch::projects::ProjectID projectID) {
    // Your implementation goes here
    printf("libraries\n");
  }

  void createLibrary( ::flowbox::batch::libs::Library& _return, const  ::flowbox::batch::libs::Library& library, const  ::flowbox::batch::projects::ProjectID projectID) {
    // Your implementation goes here
    printf("createLibrary\n");
  }

  void loadLibrary( ::flowbox::batch::libs::Library& _return, const std::string& path, const  ::flowbox::batch::projects::ProjectID projectID) {
    // Your implementation goes here
    printf("loadLibrary\n");
  }

  void unloadLibrary(const  ::flowbox::batch::libs::LibID libID, const  ::flowbox::batch::projects::ProjectID projectID) {
    // Your implementation goes here
    printf("unloadLibrary\n");
  }

  void storeLibrary(const  ::flowbox::batch::libs::LibID libID, const  ::flowbox::batch::projects::ProjectID projectID) {
    // Your implementation goes here
    printf("storeLibrary\n");
  }

  void buildLibrary(const  ::flowbox::batch::libs::LibID libID, const  ::flowbox::batch::projects::ProjectID projectID) {
    // Your implementation goes here
    printf("buildLibrary\n");
  }

  void libraryRootDef( ::flowbox::batch::defs::Definition& _return, const  ::flowbox::batch::libs::LibID libID, const  ::flowbox::batch::projects::ProjectID projectID) {
    // Your implementation goes here
    printf("libraryRootDef\n");
  }

  void defsGraph( ::flowbox::batch::defs::DefsGraph& _return, const  ::flowbox::batch::libs::LibID libID, const  ::flowbox::batch::projects::ProjectID projectID) {
    // Your implementation goes here
    printf("defsGraph\n");
  }

  void defByID( ::flowbox::batch::defs::Definition& _return, const  ::flowbox::batch::defs::DefID defID, const  ::flowbox::batch::libs::LibID libID, const  ::flowbox::batch::projects::ProjectID projectID) {
    // Your implementation goes here
    printf("defByID\n");
  }

  void addDefinition( ::flowbox::batch::defs::Definition& _return, const  ::flowbox::batch::defs::Definition& definition, const  ::flowbox::batch::defs::DefID parentID, const  ::flowbox::batch::libs::LibID libID, const  ::flowbox::batch::projects::ProjectID projectID) {
    // Your implementation goes here
    printf("addDefinition\n");
  }

  void updateDefinition(const  ::flowbox::batch::defs::Definition& definition, const  ::flowbox::batch::libs::LibID libID, const  ::flowbox::batch::projects::ProjectID projectID) {
    // Your implementation goes here
    printf("updateDefinition\n");
  }

  void removeDefinition(const  ::flowbox::batch::defs::DefID defID, const  ::flowbox::batch::libs::LibID libID, const  ::flowbox::batch::projects::ProjectID projectID) {
    // Your implementation goes here
    printf("removeDefinition\n");
  }

  void definitionChildren(std::vector< ::flowbox::batch::defs::Definition> & _return, const  ::flowbox::batch::defs::DefID defID, const  ::flowbox::batch::libs::LibID libID, const  ::flowbox::batch::projects::ProjectID projectID) {
    // Your implementation goes here
    printf("definitionChildren\n");
  }

  void definitionParent( ::flowbox::batch::defs::Definition& _return, const  ::flowbox::batch::defs::DefID defID, const  ::flowbox::batch::libs::LibID libID, const  ::flowbox::batch::projects::ProjectID projectID) {
    // Your implementation goes here
    printf("definitionParent\n");
  }

  void newTypeModule( ::flowbox::batch::types::Type& _return, const std::string& name) {
    // Your implementation goes here
    printf("newTypeModule\n");
  }

  void newTypeClass( ::flowbox::batch::types::Type& _return, const std::string& name, const std::vector<std::string> & typeparams, const std::vector< ::flowbox::batch::types::Type> & params) {
    // Your implementation goes here
    printf("newTypeClass\n");
  }

  void newTypeFunction( ::flowbox::batch::types::Type& _return, const std::string& name, const  ::flowbox::batch::types::Type& inputs, const  ::flowbox::batch::types::Type& outputs) {
    // Your implementation goes here
    printf("newTypeFunction\n");
  }

  void newTypeUdefined( ::flowbox::batch::types::Type& _return) {
    // Your implementation goes here
    printf("newTypeUdefined\n");
  }

  void newTypeNamed( ::flowbox::batch::types::Type& _return, const std::string& name, const  ::flowbox::batch::types::Type& type) {
    // Your implementation goes here
    printf("newTypeNamed\n");
  }

  void newTypeVariable( ::flowbox::batch::types::Type& _return, const std::string& name) {
    // Your implementation goes here
    printf("newTypeVariable\n");
  }

  void newTypeList( ::flowbox::batch::types::Type& _return, const  ::flowbox::batch::types::Type& type) {
    // Your implementation goes here
    printf("newTypeList\n");
  }

  void newTypeTuple( ::flowbox::batch::types::Type& _return, const std::vector< ::flowbox::batch::types::Type> & types) {
    // Your implementation goes here
    printf("newTypeTuple\n");
  }

  void nodesGraph( ::flowbox::batch::graph::GraphView& _return, const  ::flowbox::batch::defs::DefID defID, const  ::flowbox::batch::libs::LibID libID, const  ::flowbox::batch::projects::ProjectID projectID) {
    // Your implementation goes here
    printf("nodesGraph\n");
  }

  void nodeByID( ::flowbox::batch::graph::Node& _return, const  ::flowbox::batch::graph::NodeID nodeID, const  ::flowbox::batch::defs::DefID defID, const  ::flowbox::batch::libs::LibID libID, const  ::flowbox::batch::projects::ProjectID projectID) {
    // Your implementation goes here
    printf("nodeByID\n");
  }

  void addNode( ::flowbox::batch::graph::Node& _return, const  ::flowbox::batch::graph::Node& node, const  ::flowbox::batch::defs::DefID defID, const  ::flowbox::batch::libs::LibID libID, const  ::flowbox::batch::projects::ProjectID projectID) {
    // Your implementation goes here
    printf("addNode\n");
  }

  void updateNode(const  ::flowbox::batch::graph::Node& node, const  ::flowbox::batch::defs::DefID defID, const  ::flowbox::batch::libs::LibID libID, const  ::flowbox::batch::projects::ProjectID projectID) {
    // Your implementation goes here
    printf("updateNode\n");
  }

  void removeNode(const  ::flowbox::batch::graph::NodeID nodeID, const  ::flowbox::batch::defs::DefID defID, const  ::flowbox::batch::libs::LibID libID, const  ::flowbox::batch::projects::ProjectID projectID) {
    // Your implementation goes here
    printf("removeNode\n");
  }

  void connect(const  ::flowbox::batch::graph::NodeID srcNodeID, const  ::flowbox::batch::graph::PortDescriptor& srcPort, const  ::flowbox::batch::graph::NodeID dstNodeID, const  ::flowbox::batch::graph::PortDescriptor& dstPort, const  ::flowbox::batch::defs::DefID defID, const  ::flowbox::batch::libs::LibID libID, const  ::flowbox::batch::projects::ProjectID projectID) {
    // Your implementation goes here
    printf("connect\n");
  }

  void disconnect(const  ::flowbox::batch::graph::NodeID srcNodeID, const  ::flowbox::batch::graph::PortDescriptor& srcPort, const  ::flowbox::batch::graph::NodeID dstNodeID, const  ::flowbox::batch::graph::PortDescriptor& dstPort, const  ::flowbox::batch::defs::DefID defID, const  ::flowbox::batch::libs::LibID libID, const  ::flowbox::batch::projects::ProjectID projectID) {
    // Your implementation goes here
    printf("disconnect\n");
  }

  void nodeDefaults(std::map< ::flowbox::batch::graph::PortDescriptor,  ::flowbox::batch::graph::DefaultValue> & _return, const  ::flowbox::batch::graph::NodeID nodeID, const  ::flowbox::batch::defs::DefID defID, const  ::flowbox::batch::libs::LibID libID, const  ::flowbox::batch::projects::ProjectID projectID) {
    // Your implementation goes here
    printf("nodeDefaults\n");
  }

  void setNodeDefault(const  ::flowbox::batch::graph::PortDescriptor& dst, const  ::flowbox::batch::graph::DefaultValue& value, const  ::flowbox::batch::graph::NodeID nodeID, const  ::flowbox::batch::defs::DefID defID, const  ::flowbox::batch::libs::LibID libID, const  ::flowbox::batch::projects::ProjectID projectID) {
    // Your implementation goes here
    printf("setNodeDefault\n");
  }

  void removeNodeDefault(const  ::flowbox::batch::graph::PortDescriptor& dst, const  ::flowbox::batch::graph::NodeID nodeID, const  ::flowbox::batch::defs::DefID defID, const  ::flowbox::batch::libs::LibID libID, const  ::flowbox::batch::projects::ProjectID projectID) {
    // Your implementation goes here
    printf("removeNodeDefault\n");
  }

  void FS_ls(std::vector< ::flowbox::batch::fs::FSItem> & _return, const std::string& path) {
    // Your implementation goes here
    printf("FS_ls\n");
  }

  void FS_stat( ::flowbox::batch::fs::FSItem& _return, const std::string& path) {
    // Your implementation goes here
    printf("FS_stat\n");
  }

  void FS_mkdir(const std::string& path) {
    // Your implementation goes here
    printf("FS_mkdir\n");
  }

  void FS_touch(const std::string& path) {
    // Your implementation goes here
    printf("FS_touch\n");
  }

  void FS_rm(const std::string& path) {
    // Your implementation goes here
    printf("FS_rm\n");
  }

  void FS_cp(const std::string& src, const std::string& dst) {
    // Your implementation goes here
    printf("FS_cp\n");
  }

  void FS_mv(const std::string& src, const std::string& dst) {
    // Your implementation goes here
    printf("FS_mv\n");
  }

  void ping() {
    // Your implementation goes here
    printf("ping\n");
  }

  void dump() {
    // Your implementation goes here
    printf("dump\n");
  }

};

int main(int argc, char **argv) {
  int port = 9090;
  shared_ptr<BatchHandler> handler(new BatchHandler());
  shared_ptr<TProcessor> processor(new BatchProcessor(handler));
  shared_ptr<TServerTransport> serverTransport(new TServerSocket(port));
  shared_ptr<TTransportFactory> transportFactory(new TBufferedTransportFactory());
  shared_ptr<TProtocolFactory> protocolFactory(new TBinaryProtocolFactory());

  TSimpleServer server(processor, serverTransport, transportFactory, protocolFactory);
  server.serve();
  return 0;
}

