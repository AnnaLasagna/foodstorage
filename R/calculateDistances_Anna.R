#' @title calculate the Distance from the origin of a product to its supplier.  
#' @description 
#' from the data originTable which is the productOrigin and producersTable which is the producerAdress Table, the the distance form each products origin to its supplier is calculated.
#' @export

SupplierDistance <- function(originTable, producersTable){
  origin <- originTable
  producers <- producersTable
  # delete all suppliers where coordintes are missing:
  originExist <- origin[-which(is.na(origin$xCoord)),]
  
  # the coordinates in the order of the existing origins
  producerCoords <- left_join(originExist[, c("Lieferant", "Produkte_Zusammenfassung")], producers[, c("Lieferant", "xCoord", "yCoord")])
  
  # convert originExist and producerCoords to spatialpointsdataframe
  coordinates(originExist) <- ~xCoord + yCoord
  coordinates(producerCoords) <- ~xCoord + yCoord
  
  #specify crs of coordinates (from googlemaps):
  crs(producerCoords) <-  "+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext  +no_defs"
  crs(originExist) <- "+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext  +no_defs"
  
  # calculate distances from the origin to the supplier for each product
  originExist$EntfernungZwischenhaendler <- spDists(coordinates(originExist), coordinates(producerCoords), longlat=T, diagonal = T)
  
  # write distances to datatable
  Distances2 <- data.table(Lieferant = originExist$Lieferant, Ort = originExist$Ort,
                           Produkte_Zusammenfassung = originExist$Produkte_Zusammenfassung,
                           EntfernungZwischenhaendler = originExist$EntfernungZwischenhaendler)
  
  # join datatable with distances to the datatable with the origins of the products:
  origin2 <- as.data.table(left_join(origin, Distances2, by = c("Lieferant", "Produkte_Zusammenfassung", "Ort")))
  
  # ? write Distance to KK into the database table producerAdress
  ## dbWriteTable(con, "producerAdress", producers)
  return(origin2)
}



