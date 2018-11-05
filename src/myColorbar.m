function []= myColorbar(im)

myNumOfColors = 256;
myColorScale = [ (0:1/(myNumOfColors-1):1)' (0:1/(myNumOfColors-1):1)' (0:1/(myNumOfColors-1):1)' ];
imagesc(im);
colormap(myColorScale);
daspect ([1 1 1]);
axis tight;
colorbar
end