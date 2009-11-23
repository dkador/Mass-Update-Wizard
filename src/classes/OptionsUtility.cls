public class OptionsUtility {

    public static boolean getShowLabels(String[] options) {
        return getOption(options, Constants.showLabels);
    } 
    
    public static boolean getShowParentFields(String[] options) {
    	return getOption(options, Constants.showParentFields);
    }
    
    private static boolean getOption(String[] options, String option) {
        if(options != null) {
            for(String anOption : options) {
                if(anOption.equals(option)) {
                    return true;
                }
            }
        }
        return false;
    }

}