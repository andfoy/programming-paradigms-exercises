local Root File1 Folder1 File2 Visitor FindVisitor FileNode FileVisitor FileFinderVisitor CopyVisitor DeleteVisitor MoveVisitor in
class FileNode
   attr files name
   meth init(Name)
      name := Name
      files := nil
   end
   meth addFile(File)
      local S in 
         {AdjoinList @files [{File getName($)}#File] S}
	 files := S
      end
   end
   meth visit(Visitor $)
     {Visitor accept(self $)}
   end
   meth getFiles($)
     @files
   end
   meth setFiles(Files)
     files := Files
   end
   meth getChildrenNode(Name $)
      local X in
	 {CondSelect @files Name nil X}
	 X
      end
   end
   meth getName($)
     @name
   end
   meth copyNode(Name $)
      local CopyNode in
	 CopyNode = {New FileNode init(Name)}
	 {CopyNode setFiles(@files)}
	 CopyNode
      end
   end
   meth deleteChildNode(Name)
      files := {Record.subtract @files Name}
   end
end

class FileFinderVisitor
   attr name path
   meth init(Path)
      name := "FinderVisitor"
      path := Path
   end

   meth basePath(Path $)
      local DirName BasePath in
	 {List.takeDrop Path {{List.length Path} - 1} DirName BasePath}
	 DirName#BasePath
      end
   end

   meth accept(Node $)
      {self find(Node @path $)}
   end
   
   meth find(Node Path $)
      case Path of nil then Node
      [] H|T then
	 case H == {Node getName($)} of false then nil
	 [] true then
	    case T of nil then Node
	    [] Next|Rest then 
	       case {Node getChildrenNode(Next $)} of nil then nil
	       [] N then {self find(N Rest $)}
	       end
	    end
	 end
      end
   end
   
end

class DeleteVisitor from FileFinderVisitor		       
   meth accept(Node $)
     {self rm(Node $)}
   end

   meth rm(Node $)
      local DirName BaseName FindNode in
	 DirName#BaseName = {self basePath(@path $)}
	 case {self find(Node DirName $)} of nil then nil
	 [] N then {N deleteChildNode(BaseName $)}
	 end
      end
   end
end

class CopyVisitor from FileFinderVisitor 
   attr src dst
   meth init(Src Dst)
      % {FileFinderVisitor init(Src)}
      src := Src
      dst := Dst
   end

   meth accept(Root $)
     {self cp(Root $)}
   end

   meth cp(Root $)
     local SrcNode DstRoot RenameNode DstFolder DstName in
	case {self find(Root src $)} of nil then nil
	[] SrcNode then
	   DstFolder#DstName = {self basePath(dst $)}
	   case {self find(Root DstFolder $)} of nil then nil
           [] DstRoot then
	      RenameNode = {SrcNode copyNode(DstName $)}
	      {DstRoot addFile(RenameNode)}
	      RenameNode
	   end
	end
     end
   end
end

class MoveVisitor from CopyVisitor
   attr del
   meth init(Src Dst)
      %{CopyVisitor init(Src Dest)}
      % {DeleteVisitor init(Src)}
      src := Src
      dst := Dst
      del := {New DeleteVisitor init(Src)}
   end
  		     
   meth accept(Root $)
      {self mv(Root $)}
   end

   meth mv(Root $)
      local NewNode in 
	 NewNode = {self cp(Root $)}
	 _ = {@del rm(Root $)}
	 NewNode
      end
   end
end

class FileVisitor
   attr name
   meth init()
      name := "Visitor"
   end
   meth accept(FileNode $)
      {self traverse(FileNode {Record.toListInd {FileNode getFiles($)}} nil)}
      nil
   end
   meth traverse(Node NodeFiles Pending)
         {Show {Node getName($)}}
	 case NodeFiles of nil then
	    case Pending of nil then {Show 'END'}
	    [] N#H|T then {self traverse(H {Record.toListInd {H getFiles($)}} T)}
	    end
	 [] N#H|nil then {self traverse(H {Record.toListInd {H getFiles($)}} Pending)}
	 [] N#H|T then 
	    case Pending of nil then {self traverse(H {Record.toListInd {H getFiles($)}} T)}
	    [] _ then {self traverse(H {Record.toListInd {H getFiles($)}} T|Pending)}
	    end
	 end
   end
end
   Root = {New FileNode init('/')}
   File1 = {New FileNode init('file1')}
   {Root addFile(File1)}
   Folder1 = {New FileNode init('folder1')}
   File2 = {New FileNode init('file2')}
   {Folder1 addFile(File2)}
   {Root addFile(Folder1)}
   Visitor = {New FileVisitor init()}
   FindVisitor = {New FileFinderVisitor init(['/' 'file1'])}
   _ = {Root visit(Visitor $)}
   {Show {{Root visit(FindVisitor $)} getName($)}}
   
end

