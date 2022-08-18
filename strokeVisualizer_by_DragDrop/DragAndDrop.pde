import java.awt.datatransfer.Transferable;  
import java.awt.datatransfer.UnsupportedFlavorException;  
import java.awt.dnd.DnDConstants;  
import java.awt.dnd.DropTarget;  
import java.awt.dnd.DropTargetDragEvent;  
import java.awt.dnd.DropTargetDropEvent;  
import java.awt.dnd.DropTargetEvent;  
import java.awt.dnd.DropTargetListener;
import java.awt.datatransfer.DataFlavor;
import java.awt.Component;
import javax.swing.JPanel;
import java.io.File;  
import java.io.IOException;  
import java.util.List;  
import java.applet.Applet;
import javax.swing.*;
import java.awt.*;

DropTarget dropTarget;  

void initFileDrop() {
  Canvas canvas =(Canvas)surface.getNative();
  JLayeredPane pane =(JLayeredPane)canvas.getParent().getParent();
  //End Change
  dropTarget = new DropTarget( 
    pane, //Change
    new DropTargetListener() {  
    public void dragEnter(DropTargetDragEvent dtde) {
    }  
    public void dragOver(DropTargetDragEvent dtde) {
    }  
    public void dropActionChanged(DropTargetDragEvent dtde) {
    }  
    public void dragExit(DropTargetEvent dte) {
    }  
    public void drop(DropTargetDropEvent dtde) {  
      dtde.acceptDrop(DnDConstants.ACTION_COPY_OR_MOVE);  
      Transferable trans = dtde.getTransferable();  
      List<File> fileNameList = null;  
      if (trans.isDataFlavorSupported(DataFlavor.javaFileListFlavor)) {  
        try {  
          fileNameList = (List<File>)  
            trans.getTransferData(DataFlavor.javaFileListFlavor);
        } 
        catch (UnsupportedFlavorException ex) {
        } 
        catch (IOException ex) {
        }
      }  
      if (fileNameList == null) return;  
      for (File f : fileNameList){
        loadStrokeFile(f.getAbsolutePath());
      }
      println("finish!!");
    }
  }
  );
}
