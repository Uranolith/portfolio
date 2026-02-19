package de.umwelt_campus.javawp.resistor.lib;

import java.util.HashMap;
import java.util.Map;


public class ResistorLib {
    public static final long MAX_RESISTOR_VALUE = 9990000000L;
    public static final int MIN_RESISTOR_VALUE = 0;

/*
    public static final Resistor ZERO_OHM_RESISTOR = new ZeroOhmResistor();


    private static class ZeroOhmResistor extends Resistor {
        public ZeroOhmResistor() {
            super("black");
        }

        @Override
        public double getValue() {
            return 0;
        }

        @Override
        public float getTolerance() {
            return 0;
        }

        @Override
        public float getMultiplier() {
            return 1;
        }
    };
*/

    public abstract static class Resistor {
        protected static Map<String, Integer> digitCode = new HashMap<>();
        protected static Map<Integer, String> reverseDigitCode = new HashMap<>();
        protected static Map<String, Float> toleranceCode = new HashMap<>();
        protected static Map<Float, String> reverseToleranceCode = new HashMap<>();
        protected static Map<String, Float> multiplierCode = new HashMap<>();
        protected static Map<Float, String> reverseMultiplierCode = new HashMap<>();
        protected static Map<String, Integer> temperatureCode = new HashMap<>();
        protected static Map<Integer, String> reverseTemperatureCode = new HashMap<>();

/*
        enum DigitColor {
            BLACK(0), BROWN(1), RED(2), ORANGE(3), YELLOW(4), GREEN(5), BLUE(6), VIOLET(7), GRAY(8), WHITE(9);

            private final int value;
            private static final Map<Integer, DigitColor> reverseMap = new EnumMap<>(Integer.class);

            static {
                for (DigitColor color : DigitColor.values()) {
                    reverseMap.put(color.value, color);
                }
            }

            DigitColor(int value) {
                this.value = value;
            }

            public int getValue(){
                return this.value;
            }

            public static DigitColor fromValue(int value){
                return reverseMap.get(value);
            }
        }
*/

        static {
            digitCode.put("black", 0);
            digitCode.put("brown", 1);
            digitCode.put("red", 2);
            digitCode.put("orange", 3);
            digitCode.put("yellow", 4);
            digitCode.put("green", 5);
            digitCode.put("blue", 6);
            digitCode.put("violet", 7);
            digitCode.put("gray", 8);
            digitCode.put("white", 9);

            for (Map.Entry<String, Integer> entry : digitCode.entrySet()) {
                reverseDigitCode.put(entry.getValue(), entry.getKey());
            }

            toleranceCode.put("brown", 1f);
            toleranceCode.put("red", 2f);
            toleranceCode.put("green", 0.5f);
            toleranceCode.put("blue", 0.25f);
            toleranceCode.put("violet", 0.1f);
            toleranceCode.put("gray", 0.05f);
            toleranceCode.put("gold", 5f);
            toleranceCode.put("silver", 10f);

            for (Map.Entry<String, Float> entry : toleranceCode.entrySet()) {
                reverseToleranceCode.put(entry.getValue(), entry.getKey());
            }

            multiplierCode.put("black", 1f);
            multiplierCode.put("brown", 10f);
            multiplierCode.put("red", 100f);
            multiplierCode.put("orange", 1000f);
            multiplierCode.put("yellow", 10000f);
            multiplierCode.put("green", 100000f);
            multiplierCode.put("blue", 1000000f);
            multiplierCode.put("violet", 10000000f);
            multiplierCode.put("gold", 0.1f);
            multiplierCode.put("silver", 0.01f);

            for (Map.Entry<String, Float> entry : multiplierCode.entrySet()) {
                reverseMultiplierCode.put(entry.getValue(), entry.getKey());
            }

            temperatureCode.put("black", 250);
            temperatureCode.put("brown", 100);
            temperatureCode.put("red", 50);
            temperatureCode.put("orange", 15);
            temperatureCode.put("yellow", 25);
            temperatureCode.put("green", 20);
            temperatureCode.put("blue", 10);
            temperatureCode.put("violet", 5);
            temperatureCode.put("gray", 1);
            temperatureCode.put("none", 0);

            for (Map.Entry<String, Integer> entry : temperatureCode.entrySet()) {
                reverseTemperatureCode.put(entry.getValue(), entry.getKey());
            }
        }

        protected String[] bands;

        /**
         * Constructor of a Resistor object from a String array representing the color of each band.
         *
         * The input string array representing the band colors will be transformed to lowercase and whitespaces will also be removed.
         * If the Input String contains comma it will be split into individual band colors.
         * The color bands are the validated using the {@link #checkBands()} method.
         *
         * @param bands an array of strings representing the color of each band.
         */
        public Resistor(String[] bands) {
            if (bands.length >= 4 && bands.length <= 6 ){
                for (int i = 0; i < bands.length; i++) {
                    bands[i] = bands[i].toLowerCase();
                }
            }

            this.bands = bands;
            checkBands();
        }

        /**
         * Constructor of a Resistor object from a String representing the color of each band, separated by commas.
         *
         * The input string representing the band colors will be transformed to lowercase and whitespaces will also be removed.
         * If the Input String contains comma it will be split into individual band colors.
         * The color bands are the validated using the {@link #checkBands()} method.
         *
         * @param bands a string representing the colors of the bands, separated by commas.
         */
        public Resistor(String bands) {
            bands = bands.replace(" ", "");
            bands = bands.toLowerCase();
            if (bands.contains(",")) {
                this.bands = bands.split(",");
            }
            checkBands();
        }

        /**
         * Validates the band color of the Resistor
         *
         * This Method checks the color for the first and second Band of the Resistor to verify that they are valid.
         *
         * @return none
         */
        protected void checkBands() {
            //if (!DigitColor.valueOf(bands[0].toUpperCase()).name().equals(bands[0].toUpperCase())) {
            if (!digitCode.containsKey(this.bands[0])) {
                throw new IllegalArgumentException("No valid color at position 1: " + this.bands[0]);
            }
            if (this.bands.length >= 2 && !digitCode.containsKey(this.bands[1])) {
                throw new IllegalArgumentException("No valid color at position 2: " + this.bands[1]);
            }
        }

        /**
         * Returns the colors of the resistor bands as a string.
         *
         * @return a string representing the colors of the bands.
         */
        public String getColors() {
            String combinedResistorColors = "";
            for (int i = 0; i < this.bands.length; i++) {
                if (i < this.bands.length - 1) {
                    combinedResistorColors = combinedResistorColors.concat(this.bands[i] + ", ");
                } else
                    combinedResistorColors = combinedResistorColors.concat(this.bands[i]);
            }

            return combinedResistorColors;
        }

        /**
         * Returns the value of the resistor.
         *
         * @return the resistor value.
         */
        public abstract double getValue();

        /**
         * Returns the tolerance of the resistor.
         *
         * @return the resistor tolerance.
         */
        public abstract double getTolerance();

        /**
         * Returns the multiplier of the resistor.
         *
         * @return the resistor multiplier.
         */
        public abstract float getMultiplier();

        /**
         * Returns the temperature coefficient of the resistor.
         *
         * @return the temperature coefficient.
         */
        public int getTemperature() {
            return temperatureCode.get("none");
        }

        /**
         * Calculates the tolerance value of the resistor based on its value and tolerance percentage.
         *
         * This method rounds the calculated tolerance value to four decimal places.
         *
         * It multiplies the resistor's value by its tolerance percentage (divided by 100) to get the tolerance value.
         * The result is rounded to the specified number of decimal places in our case 4.
         *
         * @return the tolerance value rounded to four decimal places.
         */
        public double getToleranceValue() {
            int decimalPlaces = 4;
            double scale = Math.pow(10, decimalPlaces);
            double toleranceValue = getValue() * (getTolerance() / 100);

            /*

            A solution was found on Stackoverflow, but was not implemented because the error occurs elsewhere and the original implementation already works.

            double temp=Math.round(toleranceValue * scale) / scale;

            DecimalFormat df = new DecimalFormat("#.###");
            df.setRoundingMode(RoundingMode.CEILING);
            String formattedValue =df.format(Math.round(toleranceValue * scale) / scale);
            System.out.println(formattedValue);

            try{
            return Float.parseFloat(formattedValue);
            }
            catch( NumberFormatException e){
                return 0.0f;
            }


            System.out.println(temp);

            return temp;
            */

            return Math.round(toleranceValue * scale) / scale; // Rounding-difference does NOT occur when passing
        }

        /**
         * Creates a resistor from its value in ohms.
         *
         * @param ohms the value of the resistor in ohms (range from 0 to 9,990,000,000).
         * Default tolerance: gold (±5%).
         * Default temperature coefficient: none (0 ppm/°C).
         * @return a Resistor object representing the resistor.
         * @throws IllegalArgumentException if the resistor value is outside the valid range.
         *
         */
        public static Resistor createResistorFromValue(double ohms) {
            return createResistorFromValue(ohms, toleranceCode.get("gold"));
        }

        /**
         * Creates a resistor from its value in ohms and tolerance.
         *
         * @param ohms the value of the resistor in ohms (range from 0 to 9,990,000,000).
         * @param tolerance the tolerance of the resistor as a percentage (must be a valid tolerance value).
         * Default temperature coefficient: none (0 ppm/°C).
         * @return a Resistor object representing the resistor.
         * @throws IllegalArgumentException if the resistor value or tolerance is invalid.
         *
         */
        public static Resistor createResistorFromValue(double ohms, float tolerance) {
            return createResistorFromValue(ohms, tolerance, temperatureCode.get("none"));
        }

        //this Java Doc was created with the help of AI
        /**
         * Creates a resistor from its value in ohms, tolerance, and temperature coefficient.
         *
         * @param ohms the value of the resistor in ohms (range from 0 to 9,990,000,000).
         * @param tolerance the tolerance of the resistor as a percentage (must be a valid tolerance value).
         * @param temperature the temperature coefficient of the resistor in parts per million per degree Celsius (must be a valid temperature coefficient).
         * @return a Resistor object representing the resistor.
         * @throws IllegalArgumentException if the resistor value, tolerance, or temperature coefficient is invalid.
         */
        public static Resistor createResistorFromValue(double ohms, float tolerance, int temperature) {
        //    System.out.println(ohms);
            if (ohms > MAX_RESISTOR_VALUE || ohms <= MIN_RESISTOR_VALUE){
                throw new IllegalArgumentException("Invalid resistor value. Value must be in range from 0 to 9.99 Gigaohms: " + ohms);
            }

            String toleranceColor = reverseToleranceCode.get(tolerance);
            if (toleranceColor == null) {
                throw new IllegalArgumentException("Invalid tolerance value: " + tolerance);
            }

            String temperatureColor = reverseTemperatureCode.get(temperature);
            if (temperatureColor == null) {
                throw new IllegalArgumentException("Invalid temperature value: " + temperature);
            }

            int multiplier = 0;
            while (ohms < 100 && ohms % 10 != 0) {
                ohms *= 10;
                multiplier--;
        //        System.out.println(ohms + ", " + multiplier);
            }
        //    System.out.println("while (ohms >= 1000)");
            while (ohms >= 100 && ohms % 10 == 0) {
                ohms /= 10;
                multiplier++;
        //        System.out.println(ohms + ", " + multiplier);
            }
            String multiplierColor = reverseMultiplierCode.get((float) Math.pow(10, multiplier));

            int intOhms = (int) Math.round(ohms);
            String firstDigitColor;
            String secondDigitColor;
            String thirdDigitColor = null;

        //    System.out.println(intOhms);

            if (intOhms >= 100 || !temperatureColor.equals("none")) {
                int firstDigit = intOhms / 100;
                int secondDigit = (intOhms / 10) % 10;
                int thirdDigit = intOhms % 10;

                firstDigitColor = reverseDigitCode.get(firstDigit);
                secondDigitColor = reverseDigitCode.get(secondDigit);
                thirdDigitColor = reverseDigitCode.get(thirdDigit);
            } else {
                int firstDigit = intOhms / 10;
                int secondDigit = intOhms % 10;

                firstDigitColor = reverseDigitCode.get(firstDigit);
                secondDigitColor = reverseDigitCode.get(secondDigit);
            }

            if (temperatureColor.equals("none")) {
                if (thirdDigitColor == null) {
                    return new ResistorLib.ResistorB4(new String[]{firstDigitColor, secondDigitColor, multiplierColor, toleranceColor});
                } else {
                    return new ResistorLib.ResistorB5(new String[]{firstDigitColor, secondDigitColor, thirdDigitColor, multiplierColor, toleranceColor});
                }
            } else {
                return new ResistorLib.ResistorB6(new String[]{firstDigitColor, secondDigitColor, thirdDigitColor, multiplierColor, toleranceColor, temperatureColor});
            }
        }
    }

    /**
     * Represents a four-band resistor.
     */
    public static class ResistorB4 extends Resistor {
        /**
         * Constructor for creating a four-band resistor.
         *
         * @param bands an array of strings representing the colors of the bands.
         */
        public ResistorB4(String[] bands) {
            super(bands);
            checkBands();
        }

        /**
         * Constructor for creating a four-band resistor.
         *
         * @param bands a string representing the colors of the bands, separated by commas.
         */
        public ResistorB4(String bands) {
            super(bands);
            checkBands();
        }

        @Override
        protected void checkBands() {
            if (bands.length != 4) {
                throw new IllegalArgumentException("Four-band resistor must have 4 bands");
            }

            super.checkBands();
            if (!multiplierCode.containsKey(this.bands[2])) {
                throw new IllegalArgumentException("No valid color at position 3: " + this.bands[2]);
            }
            if (!toleranceCode.containsKey(this.bands[3])) {
                throw new IllegalArgumentException("No valid color at position 4: " + this.bands[3]);
            }
        }

        @Override
        public double getValue() {
            int decimalPlaces = 4;
            float scale = (float) Math.pow(10, decimalPlaces);
            int firstDigit = digitCode.get(bands[0]);
            int secondDigit = digitCode.get(bands[1]);
            double value = (firstDigit * 10 + secondDigit) * getMultiplier();
            return Math.round(value * scale) / scale;
        }

        @Override
        public double getTolerance() {
            return toleranceCode.get(bands[3]);
        }

        @Override
        public float getMultiplier() {
            return multiplierCode.get(bands[2]);
        }
    }

    /**
     * Represents a five-band resistor.
     */
    public static class ResistorB5 extends Resistor {
        /**
         * Constructor for creating a five-band resistor.
         *
         * @param bands an array of strings representing the colors of the bands.
         */
        public ResistorB5(String[] bands) {
            super(bands);
            checkBands();
        }

        /**
         * Constructor for creating a five-band resistor.
         *
         * @param bands a string representing the colors of the bands, separated by commas.
         */
        public ResistorB5(String bands) {
            super(bands);
            checkBands();
        }

        @Override
        protected void checkBands() {
            if (this.bands.length != 5 && !(this instanceof ResistorB6)) {
                throw new IllegalArgumentException("Five-band resistor must have 5 bands");
            }

            super.checkBands();
            if (!digitCode.containsKey(this.bands[2])) {
                throw new IllegalArgumentException("No valid color at position 3: " + this.bands[2]);
            }
            if (!multiplierCode.containsKey(this.bands[3])) {
                throw new IllegalArgumentException("No valid color at position 4: " + this.bands[3]);
            }
            if (!toleranceCode.containsKey(this.bands[4])) {
                throw new IllegalArgumentException("No valid color at position 5: " + this.bands[4]);
            }
        }

        @Override
        public double getValue() {
            int decimalPlaces = 4;
            float scale = (float) Math.pow(10, decimalPlaces);
            int firstDigit = digitCode.get(bands[0]);
            int secondDigit = digitCode.get(bands[1]);
            int thirdDigit = digitCode.get(bands[2]);
            double value = (firstDigit * 100 + secondDigit * 10 + thirdDigit) * getMultiplier();

            return Math.round(value * scale) / scale;
        }

        @Override
        public double getTolerance() {
            return toleranceCode.get(bands[4]);
        }

        @Override
        public float getMultiplier() {
            return multiplierCode.get(bands[3]);
        }
    }

    /**
     * Represents a six-band resistor.
     */
    public static class ResistorB6 extends ResistorB5 {
        /**
         * Constructor for creating a six-band resistor.
         *
         * @param bands an array of strings representing the colors of the bands.
         */
        public ResistorB6(String[] bands) {
            super(bands);
            checkBands();
        }

        /**
         * Constructor for creating a six-band resistor.
         *
         * @param bands a string representing the colors of the bands, separated by commas.
         */
        public ResistorB6(String bands) {
            super(bands);
            checkBands();
        }

        @Override
        protected void checkBands() {
            if (bands.length != 6) {
                throw new IllegalArgumentException("Six-band resistor must have 6 bands");
            }

            super.checkBands();
            if (!temperatureCode.containsKey(this.bands[5])) {
                throw new IllegalArgumentException("No valid color at position 6: " + this.bands[5]);
            }
        }

        @Override
        public int getTemperature() {
            return temperatureCode.get(bands[5]);
        }
    }
}
