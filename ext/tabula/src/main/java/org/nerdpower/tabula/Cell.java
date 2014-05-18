package org.nerdpower.tabula;

import java.awt.geom.Point2D;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

@SuppressWarnings("serial")
public class Cell extends Rectangle implements TextContainer {
    private boolean spanning;
    private boolean placeholder;
    private boolean useLineReturns = true;
    private List<TextChunk> textElements;
    
    public Cell(float top, float left, float width, float height) {
        super(top, left, width, height);
        this.setPlaceholder(false);
        this.setSpanning(false);
        this.setTextElements(new ArrayList<TextChunk>());
    }
    
    public Cell(Point2D topLeft, Point2D bottomRight) {
        super((float) topLeft.getY(), (float) topLeft.getX(), (float) (bottomRight.getX() - topLeft.getX()), (float) (bottomRight.getY() - topLeft.getY()));
    }

    @Override
    public String getText() {
        if (this.textElements.size() == 0) {
            return "";
        }
        StringBuilder sb = new StringBuilder();
        Collections.sort(this.textElements);
        double curTop = this.textElements.get(0).getTop();
        for (TextChunk tc: this.textElements) {
            if (this.useLineReturns && tc.getTop() > curTop) {
                sb.append("\r");
            }
            sb.append(tc.getText());
            curTop = tc.getTop();
        }
        return sb.toString().trim();
    }

    public boolean isSpanning() {
        return spanning;
    }

    public void setSpanning(boolean spanning) {
        this.spanning = spanning;
    }

    public boolean isPlaceholder() {
        return placeholder;
    }

    public void setPlaceholder(boolean placeholder) {
        this.placeholder = placeholder;
    }

    public boolean isUseLineReturns() {
        return useLineReturns;
    }

    public void setUseLineReturns(boolean useLineReturns) {
        this.useLineReturns = useLineReturns;
    }

    public List<TextChunk> getTextElements() {
        return textElements;
    }

    public void setTextElements(List<TextChunk> textElements) {
        this.textElements = textElements;
    }
}
