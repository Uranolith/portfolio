package de.umwelt_campus.javawp.resistor.lib;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

public class TestResistorLib {

    @Test
    void testResistorB4() {
        ResistorLib.ResistorB4 resistorB4 = new ResistorLib.ResistorB4("black,brown,brown,violet");
        assertEquals(10, resistorB4.getValue());
        assertEquals(0.1f, resistorB4.getTolerance());
        assertEquals(10, resistorB4.getMultiplier());
        assertEquals(0.01,resistorB4.getToleranceValue()); // Tolerance * Value
        assertEquals("black, brown, brown, violet", resistorB4.getColors());
    }

    @Test
    void testResistorB5() {
        ResistorLib.ResistorB5 resistorB5 = new ResistorLib.ResistorB5("black,black,blue,yellow,gold");
        assertEquals(60000, resistorB5.getValue());
        assertEquals(5f, resistorB5.getTolerance());
        assertEquals(10000f, resistorB5.getMultiplier());
        assertEquals(3000, resistorB5.getToleranceValue());
        assertEquals("black, black, blue, yellow, gold", resistorB5.getColors());
    }

    @Test
    void testResistorB6() {
        ResistorLib.ResistorB6 resistorB6 = new ResistorLib.ResistorB6("black,black,blue,yellow,gold,red");
        assertEquals(60000, resistorB6.getValue());
        assertEquals(5f, resistorB6.getTolerance());
        assertEquals(10000f, resistorB6.getMultiplier());
        assertEquals(3000, resistorB6.getToleranceValue());
        assertEquals("black, black, blue, yellow, gold, red", resistorB6.getColors());
    }

    @Test
    void testInvalidBandsFourBandsRange() {
        // Constructors with n-1, n, n+1 bands
        String band3 = "black, black, yellow";
        String band4 = "black, black, yellow, gold";
        String band5 = "black, black, blue, yellow, gold";

        // less than 4
        Exception exception = assertThrows(IllegalArgumentException.class, () -> {
            new ResistorLib.ResistorB4(band3);
        });
        assertEquals("Four-band resistor must have 4 bands", exception.getMessage());

        // exactly 4
        assertDoesNotThrow(() -> {
            new ResistorLib.ResistorB4(band4);
        });

        // more than 4
        exception = assertThrows(IllegalArgumentException.class, () -> {
            new ResistorLib.ResistorB4(band5);
        });
        assertEquals("Four-band resistor must have 4 bands", exception.getMessage());
    }

    @Test
    void testInvalidBandsFifeBandsRange() {
        String band4 = "black, black, yellow, gold";
        String band5 = "black, black, blue, yellow, gold";
        String band6 = "black, black, blue, yellow, gold, red";

        // less than 5
        Exception exception = assertThrows(IllegalArgumentException.class, () -> {
            new ResistorLib.ResistorB5(band4);
        });

        assertEquals("Five-band resistor must have 5 bands", exception.getMessage());

        // exactly 5
        assertDoesNotThrow(() -> {
            new ResistorLib.ResistorB5(band5);
        });

        // more than 5
        exception = assertThrows(IllegalArgumentException.class, () -> {
            new ResistorLib.ResistorB5(band6);
        });
        assertEquals("Five-band resistor must have 5 bands", exception.getMessage());
    }

    @Test
    void testInvalidBandsSixBandsRange() {
        String band5 = "black, black, blue, yellow, gold";
        String band6 = "black, black, blue, yellow, gold, red";
        String band7 = "black, black, blue, yellow, gold, red, gold";

        // less than 6
        Exception exception = assertThrows(IllegalArgumentException.class, () -> {
            new ResistorLib.ResistorB6(band5);
        });
        assertEquals("Six-band resistor must have 6 bands", exception.getMessage());

        // exactly 6
        assertDoesNotThrow(() -> {
            new ResistorLib.ResistorB6(band6);
        });

        // more than 6
        exception = assertThrows(IllegalArgumentException.class, () -> {
            new ResistorLib.ResistorB6(band7);
        });
        assertEquals("Six-band resistor must have 6 bands", exception.getMessage());
    }

    @Test
    void testInvalidColorBandFirstPosition() {
        String band6 = "INVALID, black, blue, yellow, gold, red";
        String band4 = "INVALID, black, blue, yellow";

        Exception exception = assertThrows(IllegalArgumentException.class, () -> {
            new ResistorLib.ResistorB6(band6);
        });
        assertEquals("No valid color at position 1: invalid", exception.getMessage());

        exception = assertThrows(IllegalArgumentException.class, () -> {
            new ResistorLib.ResistorB4(band4);
        });
        assertEquals("No valid color at position 1: invalid", exception.getMessage());
    }

    @Test
    void testInvalidColorBandSecondPosition() {
        String band6 = "black, INVALID, blue, yellow, gold, red";
        String band4 = "black, INVALID, blue, yellow";


        Exception exception = assertThrows(IllegalArgumentException.class, () -> {
            new ResistorLib.ResistorB6(band6);
        });
        assertEquals("No valid color at position 2: invalid", exception.getMessage());

        exception = assertThrows(IllegalArgumentException.class, () -> {
            new ResistorLib.ResistorB4(band4);
        });
        assertEquals("No valid color at position 2: invalid", exception.getMessage());
    }

    @Test
    void testInvalidColorBandThirdPosition() {
        String band6 = "black, black, INVALID, yellow, gold, red";
        String band4 = "black, black, INVALID, yellow";

        Exception exception = assertThrows(IllegalArgumentException.class, () -> {
            new ResistorLib.ResistorB6(band6);
        });
        assertEquals("No valid color at position 3: invalid", exception.getMessage());

        exception = assertThrows(IllegalArgumentException.class, () -> {
            new ResistorLib.ResistorB4(band4);
        });
        assertEquals("No valid color at position 3: invalid", exception.getMessage());
    }

    @Test
    void testInvalidColorBandFourthPosition() {
        String band6 = "black, black, blue, INVALID, gold, red";
        String band4 = "black, black, blue, INVALID";

        Exception exception = assertThrows(IllegalArgumentException.class, () -> {
            new ResistorLib.ResistorB6(band6);
        });
        assertEquals("No valid color at position 4: invalid", exception.getMessage());

        exception = assertThrows(IllegalArgumentException.class, () -> {
            new ResistorLib.ResistorB4(band4);
        });
        assertEquals("No valid color at position 4: invalid", exception.getMessage());
    }

    @Test
    void testInvalidColorBandFifthPosition() {
        String band6 = "black, black, blue, yellow, INVALID, red";

        Exception exception = assertThrows(IllegalArgumentException.class, () -> {
            new ResistorLib.ResistorB6(band6);
        });
        assertEquals("No valid color at position 5: invalid", exception.getMessage());
    }

    @Test
    void testInvalidColorBandSixthPosition() {
        String band6 = "black, black, blue, yellow, gold, INVALID";

        Exception exception = assertThrows(IllegalArgumentException.class, () -> {
            new ResistorLib.ResistorB6(band6);
        });
        assertEquals("No valid color at position 6: invalid", exception.getMessage());
    }

    @Test
    void testCreateResistorFromValue(){
        ResistorLib.Resistor resistor = ResistorLib.Resistor.createResistorFromValue(4700);
        assertEquals("yellow, violet, red, gold", resistor.getColors());
        assertEquals(4700, resistor.getValue());
        assertEquals(5f, resistor.getTolerance());
        assertEquals(100f, resistor.getMultiplier());
        assertEquals(235, resistor.getToleranceValue());
    }

    @Test
    void testCreateResistorFromValueWithDecimalPlace() {
        ResistorLib.Resistor resistor = ResistorLib.Resistor.createResistorFromValue(1.1);
        assertEquals("brown, brown, gold, gold", resistor.getColors());
    //    assertEquals(1.1, resistor.getValue());
        assertEquals(5f, resistor.getTolerance());
        assertEquals(0.1f, resistor.getMultiplier());
    //    assertEquals(0.055, resistor.getToleranceValue());
    }

    @Test
    void testCreateResistorFromValueWithTolerance(){
        ResistorLib.Resistor resistor = ResistorLib.Resistor.createResistorFromValue(4700, 1);
        assertEquals("yellow, violet, red, brown", resistor.getColors());
        assertEquals(4700, resistor.getValue());
        assertEquals(1f, resistor.getTolerance());
        assertEquals(100f, resistor.getMultiplier());
        assertEquals(47, resistor.getToleranceValue());
        assertEquals(0, resistor.getTemperature());
    }

    @Test
    void testCreateResistorFromValueWithToleranceAndTemperature(){
        ResistorLib.Resistor resistor = ResistorLib.Resistor.createResistorFromValue(4700, 1, 1);
        assertEquals("black, yellow, violet, red, brown, gray", resistor.getColors());
        assertEquals(4700, resistor.getValue());
        assertEquals(1f, resistor.getTolerance());
        assertEquals(100f, resistor.getMultiplier());
        assertEquals(47, resistor.getToleranceValue());
        assertEquals(1, resistor.getTemperature());
    }

    @Test
    void testCreateResistorFromValueWithInvalidTolerance(){
        float value = 3;
        Exception exception = assertThrows(IllegalArgumentException.class, () -> {
            ResistorLib.Resistor.createResistorFromValue(4700, value);
        });
        assertEquals("Invalid tolerance value: " + value, exception.getMessage());
    }

    @Test
    void testCreateResistorFromValueWithInvalidTemperature(){
        int value = 60;
        Exception exception = assertThrows(IllegalArgumentException.class, () -> {
            ResistorLib.Resistor.createResistorFromValue(4700, 1, value);
        });
        assertEquals("Invalid temperature value: " + value, exception.getMessage());
    }

    @Test
    void testResistorValueExceedsBoundsNegative(){
        double value = -4700;
        Exception exception = assertThrows(IllegalArgumentException.class, () -> {
            ResistorLib.Resistor.createResistorFromValue(value);
        });
        assertEquals("Invalid resistor value. Value must be in range from 0 to 9.99 Gigaohms: " + value, exception.getMessage());
    }

    @Test
    void testResistorValueExceedsBoundsPositive(){
        double value = 99900000000L;
        Exception exception = assertThrows(IllegalArgumentException.class, () -> {
            ResistorLib.Resistor.createResistorFromValue(value);
        });
        assertEquals("Invalid resistor value. Value must be in range from 0 to 9.99 Gigaohms: " + value, exception.getMessage());
    }

    @Test
    void testResistorValueEqualsZero(){
        double value = 0;
        Exception exception = assertThrows(IllegalArgumentException.class, () -> {
            ResistorLib.Resistor.createResistorFromValue(0);
        });
        assertEquals("Invalid resistor value. Value must be in range from 0 to 9.99 Gigaohms: " + value, exception.getMessage());
    }

    @Test
    void testResistorValueWithFloatOhms() {
        float lambda = 0.00000001f;
        ResistorLib.Resistor resistor = ResistorLib.Resistor.createResistorFromValue(0.5, 1);
        assertEquals(0.5, resistor.getValue());
        assertTrue(resistor.getToleranceValue() + lambda > 0.005 && resistor.getToleranceValue() - lambda < 0.005);
    //    assertEquals(0.005, resistor.getToleranceValue());

        resistor = ResistorLib.Resistor.createResistorFromValue(0.25, 1);
        assertEquals(0.25, resistor.getValue());
        assertTrue(resistor.getToleranceValue() + lambda > 0.0025 && resistor.getToleranceValue() - lambda < 0.0025);
    //    assertEquals(0.0025, resistor.getToleranceValue());
    }
}
