import java.awt.EventQueue;

import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.border.EmptyBorder;
import javax.swing.GroupLayout;
import javax.swing.GroupLayout.Alignment;
import java.awt.Color;
import javax.swing.LayoutStyle.ComponentPlacement;
import javax.swing.JLabel;
import java.awt.Font;
import javax.swing.JComboBox;
import javax.swing.DefaultComboBoxModel;
import javax.swing.JTable;
import javax.swing.table.DefaultTableModel;
import javax.swing.SwingConstants;
import javax.swing.JButton;
import javax.swing.JTextArea;
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import java.awt.Dimension;
import java.awt.event.KeyAdapter;
import java.io.Serial;
import javax.swing.border.BevelBorder;
import java.awt.Component;
import java.text.DecimalFormat;


import de.umwelt_campus.javawp.resistor.lib.ResistorLib;

public class Gui extends JFrame {

    @Serial
    private static final long serialVersionUID = 1L;
    private JPanel contentPane;
    private JTable table;

    /**
     * Launch the application.
     */
    public static void main(String[] args) {
        EventQueue.invokeLater(new Runnable() {
            public void run() {
                try {
                    Gui frame = new Gui();
                    frame.setVisible(true);
                    frame.setResizable(false);
                    frame.setTitle("Resistor Calculator");
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        });
    }

    /**
     * Create the frame.
     */
    public Gui() {
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setBounds(100, 100, 1475, 928);
        contentPane = new JPanel();
        contentPane.setBorder(new EmptyBorder(5, 5, 5, 5));

        setContentPane(contentPane);

        JPanel panel = new JPanel();
        panel.setBackground(new Color(255, 255, 255));

        JPanel panel_3 = new JPanel();
        panel_3.setAlignmentX(Component.LEFT_ALIGNMENT);
        panel_3.setBackground(Color.LIGHT_GRAY);

        JComboBox comboBox_band_1 = new JComboBox();
        comboBox_band_1.setMaximumSize(new Dimension(50, 25));
        comboBox_band_1.setMinimumSize(new Dimension(50, 25));
        comboBox_band_1.setModel(new DefaultComboBoxModel(new String[]{"Black", "Brown", "Red", "Orange", "Yellow", "Green", "Blue", "Violet", "Gray", "White"}));
        comboBox_band_1.setToolTipText("1. Band");
        comboBox_band_1.setFont(new Font("Calibri", Font.PLAIN, 20));

        JComboBox comboBox_band_2 = new JComboBox();
        comboBox_band_2.setAlignmentX(Component.LEFT_ALIGNMENT);
        comboBox_band_2.setMinimumSize(new Dimension(50, 25));
        comboBox_band_2.setModel(new DefaultComboBoxModel(new String[]{"Black", "Brown", "Red", "Orange", "Yellow", "Green", "Blue", "Violet", "Gray", "White"}));
        comboBox_band_2.setToolTipText("2. Band");
        comboBox_band_2.setFont(new Font("Calibri", Font.PLAIN, 20));

        JComboBox comboBox_band_3 = new JComboBox();
        comboBox_band_3.setMinimumSize(new Dimension(50, 25));
        comboBox_band_3.setVisible(false);
        comboBox_band_3.setModel(new DefaultComboBoxModel(new String[]{"Black", "Brown", "Red", "Orange", "Yellow", "Green", "Blue", "Violet", "Gray", "White"}));
        comboBox_band_3.setToolTipText("3. Band");
        comboBox_band_3.setFont(new Font("Calibri", Font.PLAIN, 20));
        comboBox_band_3.setVisible(false);

        JComboBox comboBox_multiplier = new JComboBox();
        comboBox_multiplier.setMinimumSize(new Dimension(50, 25));
        comboBox_multiplier.setModel(new DefaultComboBoxModel(new String[]{"Black", "Brown", "Red", "Orange", "Yellow", "Green", "Blue", "Violet", "Gold", "Silver"}));
        comboBox_multiplier.setToolTipText("4. Band (Multiplier)");
        comboBox_multiplier.setFont(new Font("Calibri", Font.PLAIN, 20));

        JComboBox comboBox_tolerance = new JComboBox();
        comboBox_tolerance.setMinimumSize(new Dimension(50, 25));
        comboBox_tolerance.setModel(new DefaultComboBoxModel(new String[]{"Brown", "Red", "Green", "Blue", "Violet", "Gray", "Gold", "Silver"}));
        comboBox_tolerance.setToolTipText("5. Band (Tolerance)");
        comboBox_tolerance.setFont(new Font("Calibri", Font.PLAIN, 20));

        JComboBox comboBox_tempC = new JComboBox();
        comboBox_tempC.setMinimumSize(new Dimension(50, 25));
        comboBox_tempC.setModel(new DefaultComboBoxModel(new String[]{"Black", "Brown", "Red", "Orange", "Yellow", "Green", "Blue", "Violet", "Gray"}));
        comboBox_tempC.setToolTipText("6. Band (Temperature Coefficient)");
        comboBox_tempC.setFont(new Font("Calibri", Font.PLAIN, 20));
        comboBox_tempC.setVisible(false);

        JLabel lbl_band_1 = new JLabel("1. Band");
        lbl_band_1.setFont(new Font("Calibri", Font.PLAIN, 16));

        JLabel lbl_band_2 = new JLabel("2. Band");
        lbl_band_2.setFont(new Font("Calibri", Font.PLAIN, 16));

        JLabel lbl_band_3 = new JLabel("3. Band");
        lbl_band_3.setFont(new Font("Calibri", Font.PLAIN, 16));
        lbl_band_3.setVisible(false);

        JLabel lbl_multiplier = new JLabel("Multiplier");
        lbl_multiplier.setFont(new Font("Calibri", Font.PLAIN, 16));

        JLabel lbl_tolerance = new JLabel("Tolerance");
        lbl_tolerance.setFont(new Font("Calibri", Font.PLAIN, 16));

        JLabel lbl_tempC = new JLabel("Temperature-Coefficient");
        lbl_tempC.setFont(new Font("Calibri", Font.PLAIN, 16));
        lbl_tempC.setVisible(false);

        JPanel PanelForResistorSVG = new JPanel();
        PanelForResistorSVG.setBackground(new Color(213, 178, 134, 255));

        JPanel panel_4 = new JPanel();
        panel_4.setBackground(new Color(126, 126, 126));

        JPanel panel_4_1 = new JPanel();
        panel_4_1.setBackground(new Color(126, 126, 126));

        GroupLayout gl_panel_3 = new GroupLayout(panel_3);
        gl_panel_3.setHorizontalGroup(
                gl_panel_3.createParallelGroup(Alignment.LEADING)
                        .addGroup(gl_panel_3.createSequentialGroup()
                                .addGroup(gl_panel_3.createParallelGroup(Alignment.LEADING)
                                        .addGroup(gl_panel_3.createSequentialGroup()
                                                .addGap(38)
                                                .addGroup(gl_panel_3.createParallelGroup(Alignment.TRAILING, false)
                                                        .addComponent(lbl_band_1, Alignment.LEADING, GroupLayout.DEFAULT_SIZE, GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                                                        .addComponent(comboBox_band_1, Alignment.LEADING, 0, 146, Short.MAX_VALUE))
                                                .addGap(18)
                                                .addGroup(gl_panel_3.createParallelGroup(Alignment.LEADING, false)
                                                        .addComponent(lbl_band_2, GroupLayout.DEFAULT_SIZE, GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                                                        .addComponent(comboBox_band_2, 0, 146, Short.MAX_VALUE))
                                                .addGap(18)
                                                .addGroup(gl_panel_3.createParallelGroup(Alignment.LEADING, false)
                                                        .addComponent(lbl_band_3, GroupLayout.DEFAULT_SIZE, GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                                                        .addComponent(comboBox_band_3, 0, 142, Short.MAX_VALUE))
                                                .addGap(18)
                                                .addGroup(gl_panel_3.createParallelGroup(Alignment.LEADING, false)
                                                        .addComponent(lbl_multiplier, GroupLayout.DEFAULT_SIZE, GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                                                        .addComponent(comboBox_multiplier, 0, 139, Short.MAX_VALUE))
                                                .addGap(18)
                                                .addGroup(gl_panel_3.createParallelGroup(Alignment.LEADING, false)
                                                        .addComponent(lbl_tolerance, GroupLayout.DEFAULT_SIZE, GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                                                        .addComponent(comboBox_tolerance, 0, 130, Short.MAX_VALUE))
                                                .addGap(18)
                                                .addGroup(gl_panel_3.createParallelGroup(Alignment.LEADING)
                                                        .addComponent(lbl_tempC)
                                                        .addComponent(comboBox_tempC, GroupLayout.PREFERRED_SIZE, 141, GroupLayout.PREFERRED_SIZE)))
                                        .addGroup(gl_panel_3.createSequentialGroup()
                                                .addGap(119)
                                                .addComponent(panel_4_1, GroupLayout.PREFERRED_SIZE, 178, GroupLayout.PREFERRED_SIZE)
                                                .addPreferredGap(ComponentPlacement.RELATED)
                                                .addComponent(PanelForResistorSVG, GroupLayout.PREFERRED_SIZE, 510, GroupLayout.PREFERRED_SIZE)
                                                .addPreferredGap(ComponentPlacement.RELATED)
                                                .addComponent(panel_4, GroupLayout.PREFERRED_SIZE, 178, GroupLayout.PREFERRED_SIZE)))
                                .addContainerGap(320, Short.MAX_VALUE))
        );
        gl_panel_3.setVerticalGroup(
                gl_panel_3.createParallelGroup(Alignment.TRAILING)
                        .addGroup(gl_panel_3.createSequentialGroup()
                                .addGap(128)
                                .addGroup(gl_panel_3.createParallelGroup(Alignment.TRAILING)
                                        .addComponent(PanelForResistorSVG, GroupLayout.PREFERRED_SIZE, 120, GroupLayout.PREFERRED_SIZE)
                                        .addGroup(gl_panel_3.createSequentialGroup()
                                                .addComponent(panel_4, GroupLayout.PREFERRED_SIZE, 19, GroupLayout.PREFERRED_SIZE)
                                                .addGap(53))
                                        .addGroup(gl_panel_3.createSequentialGroup()
                                                .addComponent(panel_4_1, GroupLayout.PREFERRED_SIZE, 19, GroupLayout.PREFERRED_SIZE)
                                                .addGap(52)))
                                .addPreferredGap(ComponentPlacement.RELATED, 138, Short.MAX_VALUE)
                                .addGroup(gl_panel_3.createParallelGroup(Alignment.BASELINE)
                                        .addComponent(lbl_band_1)
                                        .addComponent(lbl_band_2, GroupLayout.PREFERRED_SIZE, 20, GroupLayout.PREFERRED_SIZE)
                                        .addComponent(lbl_band_3, GroupLayout.PREFERRED_SIZE, 20, GroupLayout.PREFERRED_SIZE)
                                        .addComponent(lbl_multiplier, GroupLayout.PREFERRED_SIZE, 20, GroupLayout.PREFERRED_SIZE)
                                        .addComponent(lbl_tolerance, GroupLayout.PREFERRED_SIZE, 20, GroupLayout.PREFERRED_SIZE)
                                        .addComponent(lbl_tempC, GroupLayout.PREFERRED_SIZE, 20, GroupLayout.PREFERRED_SIZE))
                                .addPreferredGap(ComponentPlacement.RELATED)
                                .addGroup(gl_panel_3.createParallelGroup(Alignment.BASELINE)
                                        .addComponent(comboBox_band_1, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE)
                                        .addComponent(comboBox_band_2, GroupLayout.PREFERRED_SIZE, 31, GroupLayout.PREFERRED_SIZE)
                                        .addComponent(comboBox_band_3, GroupLayout.PREFERRED_SIZE, 31, GroupLayout.PREFERRED_SIZE)
                                        .addComponent(comboBox_multiplier, GroupLayout.PREFERRED_SIZE, 31, GroupLayout.PREFERRED_SIZE)
                                        .addComponent(comboBox_tolerance, GroupLayout.PREFERRED_SIZE, 31, GroupLayout.PREFERRED_SIZE)
                                        .addComponent(comboBox_tempC, GroupLayout.PREFERRED_SIZE, 31, GroupLayout.PREFERRED_SIZE))
                                .addGap(26))
        );

        JPanel panel_band_1 = new JPanel();
        panel_band_1.setBackground(new Color(0x1D1C1A));

        JPanel panel_band_2 = new JPanel();
        panel_band_2.setBackground(new Color(0x1D1C1A));

        JPanel panel_band_3 = new JPanel();
        panel_band_3.setBackground(new Color(0x1D1C1A));
        panel_band_3.setVisible(false);

        JPanel panel_tempC = new JPanel();
        panel_tempC.setBackground(new Color(0x1D1C1A));
        panel_tempC.setVisible(false);

        JPanel panel_tolerance = new JPanel();
        panel_tolerance.setBackground(new Color(0x653A19));

        JPanel panel_multiplier = new JPanel();
        panel_multiplier.setBackground(new Color(0x1D1C1A));

        GroupLayout gl_PanelForResistorSVG = new GroupLayout(PanelForResistorSVG);
        gl_PanelForResistorSVG.setHorizontalGroup(
                gl_PanelForResistorSVG.createParallelGroup(Alignment.LEADING)
                        .addGroup(gl_PanelForResistorSVG.createSequentialGroup()
                                .addGap(35)
                                .addComponent(panel_band_1, GroupLayout.PREFERRED_SIZE, 16, GroupLayout.PREFERRED_SIZE)
                                .addGap(49)
                                .addComponent(panel_band_2, GroupLayout.PREFERRED_SIZE, 16, GroupLayout.PREFERRED_SIZE)
                                .addGap(56)
                                .addComponent(panel_band_3, GroupLayout.PREFERRED_SIZE, 16, GroupLayout.PREFERRED_SIZE)
                                .addGap(48)
                                .addComponent(panel_multiplier, GroupLayout.PREFERRED_SIZE, 16, GroupLayout.PREFERRED_SIZE)
                                .addPreferredGap(ComponentPlacement.RELATED, 146, Short.MAX_VALUE)
                                .addComponent(panel_tolerance, GroupLayout.PREFERRED_SIZE, 16, GroupLayout.PREFERRED_SIZE)
                                .addGap(48)
                                .addComponent(panel_tempC, GroupLayout.PREFERRED_SIZE, 16, GroupLayout.PREFERRED_SIZE)
                                .addGap(32))
        );
        gl_PanelForResistorSVG.setVerticalGroup(
                gl_PanelForResistorSVG.createParallelGroup(Alignment.LEADING)
                        .addComponent(panel_band_1, GroupLayout.DEFAULT_SIZE, 120, Short.MAX_VALUE)
                        .addGroup(gl_PanelForResistorSVG.createSequentialGroup()
                                .addComponent(panel_band_2, GroupLayout.PREFERRED_SIZE, 120, GroupLayout.PREFERRED_SIZE)
                                .addContainerGap())
                        .addGroup(gl_PanelForResistorSVG.createSequentialGroup()
                                .addComponent(panel_band_3, GroupLayout.PREFERRED_SIZE, 120, GroupLayout.PREFERRED_SIZE)
                                .addContainerGap())
                        .addGroup(gl_PanelForResistorSVG.createSequentialGroup()
                                .addComponent(panel_tempC, GroupLayout.PREFERRED_SIZE, 120, GroupLayout.PREFERRED_SIZE)
                                .addContainerGap())
                        .addGroup(gl_PanelForResistorSVG.createSequentialGroup()
                                .addComponent(panel_tolerance, GroupLayout.PREFERRED_SIZE, 120, GroupLayout.PREFERRED_SIZE)
                                .addContainerGap())
                        .addGroup(gl_PanelForResistorSVG.createSequentialGroup()
                                .addComponent(panel_multiplier, GroupLayout.PREFERRED_SIZE, 120, GroupLayout.PREFERRED_SIZE)
                                .addContainerGap())
        );
        PanelForResistorSVG.setLayout(gl_PanelForResistorSVG);
        panel_3.setLayout(gl_panel_3);

        JPanel panel_1 = new JPanel();
        panel_1.setBackground(new Color(192, 192, 192));
        GroupLayout gl_contentPane = new GroupLayout(contentPane);
        gl_contentPane.setHorizontalGroup(
                gl_contentPane.createParallelGroup(Alignment.LEADING)
                        .addGroup(gl_contentPane.createSequentialGroup()
                                .addComponent(panel, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE)
                                .addGap(18)
                                .addGroup(gl_contentPane.createParallelGroup(Alignment.LEADING)
                                        .addComponent(panel_1, GroupLayout.DEFAULT_SIZE, 2029, Short.MAX_VALUE)
                                        .addComponent(panel_3, GroupLayout.DEFAULT_SIZE, 2029, Short.MAX_VALUE))
                                .addContainerGap())
        );
        gl_contentPane.setVerticalGroup(
                gl_contentPane.createParallelGroup(Alignment.TRAILING)
                        .addGroup(gl_contentPane.createSequentialGroup()
                                .addGroup(gl_contentPane.createParallelGroup(Alignment.LEADING)
                                        .addComponent(panel, GroupLayout.DEFAULT_SIZE, 871, Short.MAX_VALUE)
                                        .addGroup(gl_contentPane.createSequentialGroup()
                                                .addComponent(panel_3, GroupLayout.PREFERRED_SIZE, 469, GroupLayout.PREFERRED_SIZE)
                                                .addPreferredGap(ComponentPlacement.RELATED)
                                                .addComponent(panel_1, GroupLayout.DEFAULT_SIZE, 396, Short.MAX_VALUE)))
                                .addContainerGap())
        );

        JButton btn_calculate = new JButton("Calculate Resitance");
        btn_calculate.setFont(new Font("Calibri", Font.PLAIN, 20));

        JTextArea txt_output = new JTextArea();
        txt_output.setFont(new Font("Monospaced", Font.PLAIN, 16));
        txt_output.setText("");
        txt_output.setForeground(Color.BLACK);
        txt_output.setBorder(new BevelBorder(BevelBorder.LOWERED, null, null, null, null));
        txt_output.setEditable(false);

        JButton btn_calculate_colors = new JButton("Calculate Colors");
        btn_calculate_colors.setFont(new Font("Calibri", Font.PLAIN, 20));

        JLabel lblNewLabel_1 = new JLabel("Output:");
        lblNewLabel_1.setFont(new Font("Calibri", Font.PLAIN, 16));
/*
        JTextArea txt_input = new JTextArea();
        txt_input.setFont(new Font("Monospaced", Font.PLAIN, 16));
        txt_input.setText("");
        txt_input.setForeground(Color.BLACK);
        txt_input.setBorder(new BevelBorder(BevelBorder.LOWERED, null, null, null, null));
        txt_input.setEditable(true);

        JLabel lblNewLabel_1_1 = new JLabel("Input:");
        lblNewLabel_1_1.setFont(new Font("Calibri", Font.PLAIN, 16));

        GroupLayout gl_panel_1 = new GroupLayout(panel_1);
        gl_panel_1.setHorizontalGroup(
                gl_panel_1.createParallelGroup(Alignment.LEADING)
                        .addGroup(gl_panel_1.createSequentialGroup()
                                .addGap(53)
                                .addGroup(gl_panel_1.createParallelGroup(Alignment.LEADING, false)
                                        .addComponent(lblNewLabel_1, GroupLayout.PREFERRED_SIZE, 215, GroupLayout.PREFERRED_SIZE)
                                        .addComponent(btn_calculate, GroupLayout.DEFAULT_SIZE, GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                                        .addGroup(gl_panel_1.createSequentialGroup()
                                                .addComponent(txt_output, GroupLayout.PREFERRED_SIZE, 456, GroupLayout.PREFERRED_SIZE)
                                                .addPreferredGap(ComponentPlacement.RELATED)))
                                .addGap(99)
                                .addGroup(gl_panel_1.createParallelGroup(Alignment.LEADING, false)
                                        .addComponent(lblNewLabel_1_1, GroupLayout.PREFERRED_SIZE, 215, GroupLayout.PREFERRED_SIZE)
                                        .addComponent(txt_input, GroupLayout.DEFAULT_SIZE, 441, Short.MAX_VALUE)
                                        .addComponent(btn_calculate_colors, GroupLayout.DEFAULT_SIZE, GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
                                .addGap(980))
        );
        gl_panel_1.setVerticalGroup(
                gl_panel_1.createParallelGroup(Alignment.LEADING)
                        .addGroup(gl_panel_1.createSequentialGroup()
                                .addGap(24)
                                .addGroup(gl_panel_1.createParallelGroup(Alignment.TRAILING)
                                        .addComponent(btn_calculate, GroupLayout.PREFERRED_SIZE, 51, GroupLayout.PREFERRED_SIZE)
                                        .addComponent(btn_calculate_colors, GroupLayout.PREFERRED_SIZE, 51, GroupLayout.PREFERRED_SIZE))
                                .addGap(18)
                                .addGroup(gl_panel_1.createParallelGroup(Alignment.BASELINE)
                                        .addComponent(lblNewLabel_1, GroupLayout.PREFERRED_SIZE, 20, GroupLayout.PREFERRED_SIZE)
                                        .addComponent(lblNewLabel_1_1, GroupLayout.PREFERRED_SIZE, 20, GroupLayout.PREFERRED_SIZE))
                                .addPreferredGap(ComponentPlacement.RELATED)
                                .addGroup(gl_panel_1.createParallelGroup(Alignment.BASELINE)
                                        .addComponent(txt_output, GroupLayout.DEFAULT_SIZE, 254, Short.MAX_VALUE)
                                        .addComponent(txt_input, GroupLayout.DEFAULT_SIZE, 254, Short.MAX_VALUE))
                                .addGap(23))
        );
        panel_1.setLayout(gl_panel_1);
        */

        JTextArea txt_input_ohm = new JTextArea();
        txt_input_ohm.setText("");
        txt_input_ohm.setFont(new Font("Monospaced", Font.PLAIN, 16));
        txt_input_ohm.setForeground(Color.BLACK);
        txt_input_ohm.setEditable(true);
        txt_input_ohm.setBorder(new BevelBorder(BevelBorder.LOWERED, null, null, null, null));

        JLabel lbl_input_ohm = new JLabel("Ohm:");
        lbl_input_ohm.setFont(new Font("Calibri", Font.PLAIN, 16));

        JTextArea txt_input_tolerance = new JTextArea();
        txt_input_tolerance.setText("");
        txt_input_tolerance.setFont(new Font("Monospaced", Font.PLAIN, 16));
        txt_input_tolerance.setForeground(Color.BLACK);
        txt_input_tolerance.setEditable(true);
        txt_input_tolerance.setBorder(new BevelBorder(BevelBorder.LOWERED, null, null, null, null));

        JLabel lbl_input_tolerance = new JLabel("Tolerance (%):");
        lbl_input_tolerance.setFont(new Font("Calibri", Font.PLAIN, 16));

        JTextArea txt_input_tempC = new JTextArea();
        txt_input_tempC.setText("");
        txt_input_tempC.setFont(new Font("Monospaced", Font.PLAIN, 16));
        txt_input_tempC.setForeground(Color.BLACK);
        txt_input_tempC.setEditable(true);
        txt_input_tempC.setBorder(new BevelBorder(BevelBorder.LOWERED, null, null, null, null));

        JLabel lbl_input_tempC = new JLabel("Temperature-Coefficient:");
        lbl_input_tempC.setFont(new Font("Calibri", Font.PLAIN, 16));
        GroupLayout gl_panel_1 = new GroupLayout(panel_1);
        gl_panel_1.setHorizontalGroup(
                gl_panel_1.createParallelGroup(Alignment.LEADING)
                        .addGroup(gl_panel_1.createSequentialGroup()
                                .addGap(53)
                                .addGroup(gl_panel_1.createParallelGroup(Alignment.LEADING)
                                        .addComponent(txt_output, GroupLayout.PREFERRED_SIZE, 550, GroupLayout.PREFERRED_SIZE)
                                        .addComponent(lblNewLabel_1, GroupLayout.PREFERRED_SIZE, 215, GroupLayout.PREFERRED_SIZE)
                                        .addGroup(gl_panel_1.createSequentialGroup()
                                                .addGap(121)
                                                .addComponent(btn_calculate, GroupLayout.PREFERRED_SIZE, 276, GroupLayout.PREFERRED_SIZE)))
                                .addGroup(gl_panel_1.createParallelGroup(Alignment.LEADING)
                                        .addGroup(gl_panel_1.createSequentialGroup()
                                                .addGap(94)
                                                .addGroup(gl_panel_1.createParallelGroup(Alignment.LEADING)
                                                        .addComponent(lbl_input_tempC, GroupLayout.PREFERRED_SIZE, 215, GroupLayout.PREFERRED_SIZE)
                                                        .addComponent(txt_input_tempC, GroupLayout.PREFERRED_SIZE, 350, GroupLayout.PREFERRED_SIZE)
                                                        .addComponent(lbl_input_ohm, GroupLayout.PREFERRED_SIZE, 215, GroupLayout.PREFERRED_SIZE)
                                                        .addComponent(txt_input_ohm, GroupLayout.PREFERRED_SIZE, 350, GroupLayout.PREFERRED_SIZE)
                                                        .addComponent(lbl_input_tolerance, GroupLayout.PREFERRED_SIZE, 215, GroupLayout.PREFERRED_SIZE)
                                                        .addComponent(txt_input_tolerance, GroupLayout.PREFERRED_SIZE, 350, GroupLayout.PREFERRED_SIZE)))
                                        .addGroup(gl_panel_1.createSequentialGroup()
                                                .addGap(135)
                                                .addComponent(btn_calculate_colors, GroupLayout.PREFERRED_SIZE, 273, GroupLayout.PREFERRED_SIZE)))
                                .addGap(775))
        );
        gl_panel_1.setVerticalGroup(
                gl_panel_1.createParallelGroup(Alignment.TRAILING)
                        .addGroup(gl_panel_1.createSequentialGroup()
                                .addGap(24)
                                .addGroup(gl_panel_1.createParallelGroup(Alignment.TRAILING)
                                        .addComponent(btn_calculate, GroupLayout.PREFERRED_SIZE, 51, GroupLayout.PREFERRED_SIZE)
                                        .addComponent(btn_calculate_colors, GroupLayout.PREFERRED_SIZE, 51, GroupLayout.PREFERRED_SIZE))
                                .addGap(18)
                                .addGroup(gl_panel_1.createParallelGroup(Alignment.LEADING)
                                        .addGroup(gl_panel_1.createParallelGroup(Alignment.LEADING)
                                                .addComponent(lblNewLabel_1, GroupLayout.PREFERRED_SIZE, 20, GroupLayout.PREFERRED_SIZE)
                                                .addGroup(gl_panel_1.createSequentialGroup()
                                                        .addPreferredGap(ComponentPlacement.RELATED)
                                                        .addComponent(lbl_input_ohm, GroupLayout.PREFERRED_SIZE, 20, GroupLayout.PREFERRED_SIZE)
                                                        .addPreferredGap(ComponentPlacement.RELATED)
                                                        .addGroup(gl_panel_1.createParallelGroup(Alignment.BASELINE)
                                                                .addComponent(txt_output, GroupLayout.DEFAULT_SIZE, 199, Short.MAX_VALUE)
                                                                .addGroup(gl_panel_1.createSequentialGroup()
                                                                        .addComponent(txt_input_ohm, GroupLayout.PREFERRED_SIZE, 30, GroupLayout.PREFERRED_SIZE)
                                                                        .addGap(35)
                                                                        .addComponent(lbl_input_tolerance, GroupLayout.PREFERRED_SIZE, 20, GroupLayout.PREFERRED_SIZE)
                                                                        .addPreferredGap(ComponentPlacement.RELATED)
                                                                        .addComponent(txt_input_tolerance, GroupLayout.PREFERRED_SIZE, 30, GroupLayout.PREFERRED_SIZE)))))
                                        .addGroup(Alignment.TRAILING, gl_panel_1.createSequentialGroup()
                                                .addGap(183)
                                                .addComponent(lbl_input_tempC, GroupLayout.PREFERRED_SIZE, 20, GroupLayout.PREFERRED_SIZE)
                                                .addPreferredGap(ComponentPlacement.RELATED)
                                                .addComponent(txt_input_tempC, GroupLayout.PREFERRED_SIZE, 30, GroupLayout.PREFERRED_SIZE)))
                                .addGap(78))
        );
        panel_1.setLayout(gl_panel_1);

        JLabel lblNewLabel_heading1 = new JLabel("Resistor Calculator");
        lblNewLabel_heading1.setFont(new Font("Calibri", Font.BOLD | Font.ITALIC, 37));

        JLabel lblNewLabel_heading2 = new JLabel("Choose amount of Bands:");
        lblNewLabel_heading2.setFont(new Font("Calibri", Font.PLAIN, 20));
        lblNewLabel_heading2.setBackground(new Color(128, 128, 128));

        JComboBox comboBox_chooseBands = new JComboBox();

        comboBox_chooseBands.setFont(new Font("Calibri", Font.PLAIN, 16));
        comboBox_chooseBands.setModel(new DefaultComboBoxModel(new String[]{"4 Band", "5 Band", "6 Band"}));

        JPanel panel_2 = new JPanel();
        GroupLayout gl_panel = new GroupLayout(panel);
        gl_panel.setHorizontalGroup(
                gl_panel.createParallelGroup(Alignment.LEADING)
                        .addComponent(panel_2, GroupLayout.PREFERRED_SIZE, 329, Short.MAX_VALUE)
                        .addGroup(gl_panel.createSequentialGroup()
                                .addGap(15)
                                .addGroup(gl_panel.createParallelGroup(Alignment.LEADING)
                                        .addComponent(lblNewLabel_heading1)
                                        .addComponent(lblNewLabel_heading2, GroupLayout.PREFERRED_SIZE, 230, GroupLayout.PREFERRED_SIZE)
                                        .addComponent(comboBox_chooseBands, GroupLayout.PREFERRED_SIZE, 135, GroupLayout.PREFERRED_SIZE))
                                .addContainerGap(24, Short.MAX_VALUE))
        );
        gl_panel.setVerticalGroup(
                gl_panel.createParallelGroup(Alignment.LEADING)
                        .addGroup(gl_panel.createSequentialGroup()
                                .addGap(17)
                                .addComponent(lblNewLabel_heading1)
                                .addPreferredGap(ComponentPlacement.RELATED)
                                .addComponent(lblNewLabel_heading2)
                                .addPreferredGap(ComponentPlacement.RELATED)
                                .addComponent(comboBox_chooseBands, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE)
                                .addPreferredGap(ComponentPlacement.RELATED, 424, Short.MAX_VALUE)
                                .addComponent(panel_2, GroupLayout.PREFERRED_SIZE, 288, GroupLayout.PREFERRED_SIZE))
        );

        table = new JTable();
        table.setModel(new DefaultTableModel(
                new Object[][]{
                        {"Black", "0", "x 1", null},
                        {"Brown", "1", "x 10", "± 1%"},
                        {"Red", "2", "x 100", "± 2%"},
                        {"Orange", "3", "x 1K", null},
                        {"Yellow", "4", "x 10K", null},
                        {"Green", "5", "x 100K", "± 0.5%"},
                        {"Blue", "6", "x 1M", "± 0.25%"},
                        {"Violet", "7", "x 10M", "± 0.1%"},
                        {"Grey", "8", null, "± 0.05%"},
                        {"White", "9", null, null},
                        {"Gold", null, "x 0.1", "± 5%"},
                        {"Silver", null, "x 0.01", "± 10%"},
                },
                new String[]{
                        "New column", "New column", "New column", "New column"
                }
        ) {
            boolean[] columnEditables = new boolean[]{
                    false, false, false, false
            };

            public boolean isCellEditable(int row, int column) {
                return columnEditables[column];
            }
        });

        table.getColumnModel().getColumn(3).setPreferredWidth(79);
        table.setFont(new Font("Calibri", Font.PLAIN, 14));

        JLabel lblNewLabel_3 = new JLabel("Color");
        lblNewLabel_3.setHorizontalAlignment(SwingConstants.CENTER);
        lblNewLabel_3.setFont(new Font("Calibri", Font.BOLD, 16));

        JLabel lblNewLabel_3_1 = new JLabel("BSF");
        lblNewLabel_3_1.setHorizontalAlignment(SwingConstants.CENTER);
        lblNewLabel_3_1.setFont(new Font("Calibri", Font.BOLD, 16));

        JLabel lblNewLabel_3_2 = new JLabel("Multiplier");
        lblNewLabel_3_2.setHorizontalAlignment(SwingConstants.CENTER);
        lblNewLabel_3_2.setFont(new Font("Calibri", Font.BOLD, 16));

        JLabel lblNewLabel_3_3 = new JLabel("Tolerance");
        lblNewLabel_3_3.setHorizontalAlignment(SwingConstants.CENTER);
        lblNewLabel_3_3.setFont(new Font("Calibri", Font.BOLD, 16));

        JLabel lblNewLabel_2 = new JLabel("Legend:");
        lblNewLabel_2.setFont(new Font("Calibri", Font.PLAIN, 20));

        GroupLayout gl_panel_2 = new GroupLayout(panel_2);
        gl_panel_2.setHorizontalGroup(
                gl_panel_2.createParallelGroup(Alignment.LEADING)
                        .addGroup(gl_panel_2.createSequentialGroup()
                                .addGroup(gl_panel_2.createParallelGroup(Alignment.LEADING)
                                        .addComponent(table, GroupLayout.DEFAULT_SIZE, 320, Short.MAX_VALUE)
                                        .addGroup(gl_panel_2.createSequentialGroup()
                                                .addContainerGap()
                                                .addComponent(lblNewLabel_3, GroupLayout.PREFERRED_SIZE, 74, GroupLayout.PREFERRED_SIZE)
                                                .addGap(1)
                                                .addComponent(lblNewLabel_3_1, GroupLayout.PREFERRED_SIZE, 78, GroupLayout.PREFERRED_SIZE)
                                                .addPreferredGap(ComponentPlacement.RELATED)
                                                .addComponent(lblNewLabel_3_2, GroupLayout.DEFAULT_SIZE, GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                                                .addPreferredGap(ComponentPlacement.UNRELATED)
                                                .addComponent(lblNewLabel_3_3, GroupLayout.PREFERRED_SIZE, 75, GroupLayout.PREFERRED_SIZE)
                                                .addGap(8))
                                        .addGroup(gl_panel_2.createSequentialGroup()
                                                .addContainerGap()
                                                .addComponent(lblNewLabel_2)))
                                .addContainerGap())
        );
        gl_panel_2.setVerticalGroup(
                gl_panel_2.createParallelGroup(Alignment.TRAILING)
                        .addGroup(gl_panel_2.createSequentialGroup()
                                .addContainerGap(52, Short.MAX_VALUE)
                                .addComponent(lblNewLabel_2)
                                .addGap(18)
                                .addGroup(gl_panel_2.createParallelGroup(Alignment.BASELINE)
                                        .addComponent(lblNewLabel_3)
                                        .addComponent(lblNewLabel_3_1, GroupLayout.PREFERRED_SIZE, 20, GroupLayout.PREFERRED_SIZE)
                                        .addComponent(lblNewLabel_3_2, GroupLayout.PREFERRED_SIZE, 20, GroupLayout.PREFERRED_SIZE)
                                        .addComponent(lblNewLabel_3_3, GroupLayout.PREFERRED_SIZE, 20, GroupLayout.PREFERRED_SIZE))
                                .addPreferredGap(ComponentPlacement.RELATED)
                                .addComponent(table, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE))
        );
        panel_2.setLayout(gl_panel_2);
        panel.setLayout(gl_panel);
        contentPane.setLayout(gl_contentPane);


        // ------------------------------------------------
        // ------------------------------------------------
        // ------------------------------------------------
        // -------Implementation of action handling--------
        // ------------------------------------------------
        // ------------------------------------------------
        // ------------------------------------------------


        btn_calculate.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                int selectedIndex = comboBox_chooseBands.getSelectedIndex();
                String bandContent = "";
                String calculatedValue = "";

                ResistorLib.Resistor newResistor = null;

                // Check the selected band type and concatenate the band contents
                switch (selectedIndex) {
                    case 0:
                        // 4-band resistor
                        bandContent = bandContent.concat(comboBox_band_1.getSelectedItem().toString()
                                + "," + comboBox_band_2.getSelectedItem().toString()
                                + "," + comboBox_multiplier.getSelectedItem().toString()
                                + "," + comboBox_tolerance.getSelectedItem().toString()
                        );
                        newResistor = new ResistorLib.ResistorB4(bandContent);
                        txt_output.append("4-Band Resistor\n");
                        break;

                    case 1:
                        // 5-band resistor
                        bandContent = bandContent.concat(comboBox_band_1.getSelectedItem().toString()
                                + "," + comboBox_band_2.getSelectedItem().toString()
                                + "," + comboBox_band_3.getSelectedItem().toString()
                                + "," + comboBox_multiplier.getSelectedItem().toString()
                                + "," + comboBox_tolerance.getSelectedItem().toString()
                        );
                        newResistor = new ResistorLib.ResistorB5(bandContent);
                        txt_output.append("5-Band Resistor\n");
                        break;

                    case 2:
                        // 6-band resistor
                        bandContent = bandContent.concat(comboBox_band_1.getSelectedItem().toString()
                                + "," + comboBox_band_2.getSelectedItem().toString()
                                + "," + comboBox_band_3.getSelectedItem().toString()
                                + "," + comboBox_multiplier.getSelectedItem().toString()
                                + "," + comboBox_tolerance.getSelectedItem().toString()
                                + "," + comboBox_tempC.getSelectedItem().toString()
                        );
                        newResistor = new ResistorLib.ResistorB6(bandContent);
                        txt_output.append("6-Band Resistor\n");
                        break;
                }

                // Format the resistor value
                String valueString = new String(String.format("%.1f", newResistor.getValue()) + " Ω");
                if (newResistor.getValue() >= 1000000000) {
                    valueString = new String(String.format("%.1f", newResistor.getValue() / 1000000000) + " GΩ");
                } else if (newResistor.getValue() >= 1000000) {
                    valueString = new String(String.format("%.1f", newResistor.getValue() / 1000000) + " MΩ");
                } else if (newResistor.getValue() >= 1000) {
                    valueString = new String(String.format("%.1f", newResistor.getValue() / 1000) + " kΩ");
                } else if (newResistor.getValue() < 1) {
                    valueString = new String(String.format("%.1f", newResistor.getValue() * 1000) + " mΩ");
                }

                // Format the multiplier value
                String multiplierString = new String(String.format("%.0f", newResistor.getMultiplier()));
                if (newResistor.getMultiplier() < 0) {
                    multiplierString = new String(String.format("%.2f", newResistor.getMultiplier()));
                }

                // Format the tolerance value
                String toleranceString = new String(String.format("%.0f", newResistor.getTolerance()));
                if (newResistor.getTolerance() < 0) {
                    toleranceString = new String(String.format("%.2f", newResistor.getTolerance()));
                }

                // Format the tolerance value string
                String toleranceValueString = new String(String.format("%.1f", newResistor.getToleranceValue()) + " Ω");
                if (newResistor.getToleranceValue() >= 1000000) {
                    toleranceValueString = new String(String.format("%.1f", newResistor.getToleranceValue() / 1000000) + " MΩ");
                } else if (newResistor.getToleranceValue() >= 1000) {
                    toleranceValueString = new String(String.format("%.1f", newResistor.getToleranceValue() / 1000) + " kΩ");
                } else if (newResistor.getToleranceValue() < 1) {
                    toleranceValueString = new String(String.format("%.1f", newResistor.getToleranceValue() * 1000) + " mΩ");
                }

                txt_output.setText(
                        " Colors: " + newResistor.getColors()
                        + "\n Value: " + valueString
                        + "\n Multiplier: " + multiplierString
                        + "\n Tolerance: " + toleranceString + " %"
                        + "\n Tolerance Value: " + toleranceValueString
                );

                // If the resistor is of type ResistorB6, add temperature information
                if (newResistor.getClass() == ResistorLib.ResistorB6.class) {
                    txt_output.append("\n Temperature: " + String.valueOf(newResistor.getTemperature() + " ppm/°C"));
                }
            }
        });


        btn_calculate_colors.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                // Get and clean the input values from the text fields
                String ohmValueString = txt_input_ohm.getText();
                ohmValueString = ohmValueString.replace(",", ".");
                ohmValueString = ohmValueString.replace(" ", "");
                ohmValueString = ohmValueString.replace("\n", "");

                String toleranceValueString = txt_input_tolerance.getText();
                toleranceValueString = toleranceValueString.replace(",", ".");
                toleranceValueString = toleranceValueString.replace(" ", "");
                toleranceValueString = toleranceValueString.replace("\n", "");
                if (toleranceValueString.isEmpty()) {
                    toleranceValueString = "5";
                }

                String tempCValueString = txt_input_tempC.getText();
                tempCValueString = tempCValueString.replace(" ", "");
                tempCValueString = tempCValueString.replace("\n", "");
                if (tempCValueString.isEmpty()) {
                    tempCValueString = "0";
                }

                // Validate the input values
                // match statement was generated by AI
                if (ohmValueString.matches("[0-9]*\\.?[0-9]*") && !ohmValueString.matches(".*\\..*\\..*")
                        && ohmValueString.matches("^0*([0-9]{1,3})(?:[.,][0-9]{1,3})*0*$")
                        && toleranceValueString.matches("[0-9]*\\.?[0-9]*") && !toleranceValueString.matches(".*\\..*\\..*")
                        && tempCValueString.matches("^[0-9]+$")) {

                    // Create a new resistor from the input values
                    ResistorLib.Resistor newResistor = ResistorLib.Resistor.createResistorFromValue(
                            Double.parseDouble(ohmValueString),
                            Float.parseFloat(toleranceValueString),
                            Integer.parseInt(tempCValueString)
                    );

                    //System.out.println(newResistor.getClass().toString());

                    // Set the selected item in the comboBox_chooseBands based on the resistor type
                    if (newResistor.getClass() == ResistorLib.ResistorB4.class) {
                        comboBox_chooseBands.setSelectedItem(comboBox_chooseBands.getItemAt(0));
                    } else if (newResistor.getClass() == ResistorLib.ResistorB5.class) {
                        comboBox_chooseBands.setSelectedItem(comboBox_chooseBands.getItemAt(1));
                    } else {
                        comboBox_chooseBands.setSelectedItem(comboBox_chooseBands.getItemAt(2));
                    }

                    // Get and format the color bands of the resistor
                    String bandString = newResistor.getColors();
                    bandString = bandString.replace(" ", "");
                    String[] bands = bandString.split(",");

                    for (int i = 0; i < bands.length; i++) {
                        bands[i] = Character.toUpperCase(bands[i].charAt(0)) + bands[i].substring(1);
                    }

                    // Set the selected items in the combo boxes based on the color bands
                    int index = ((DefaultComboBoxModel<String>) comboBox_band_1.getModel()).getIndexOf(bands[0]);
                    comboBox_band_1.setSelectedItem(comboBox_band_1.getItemAt(index));

                    index = ((DefaultComboBoxModel<String>) comboBox_band_2.getModel()).getIndexOf(bands[1]);
                    comboBox_band_2.setSelectedItem(comboBox_band_2.getItemAt(index));

                    if (newResistor.getClass() == ResistorLib.ResistorB4.class) {
                        index = ((DefaultComboBoxModel<String>) comboBox_multiplier.getModel()).getIndexOf(bands[2]);
                        comboBox_multiplier.setSelectedItem(comboBox_multiplier.getItemAt(index));

                        index = ((DefaultComboBoxModel<String>) comboBox_tolerance.getModel()).getIndexOf(bands[3]);
                        comboBox_tolerance.setSelectedItem(comboBox_tolerance.getItemAt(index));
                    } else {
                        index = ((DefaultComboBoxModel<String>) comboBox_band_3.getModel()).getIndexOf(bands[2]);
                        comboBox_band_3.setSelectedItem(comboBox_band_3.getItemAt(index));

                        index = ((DefaultComboBoxModel<String>) comboBox_tolerance.getModel()).getIndexOf(bands[4]);
                        comboBox_tolerance.setSelectedItem(comboBox_tolerance.getItemAt(index));

                        if (newResistor.getClass() == ResistorLib.ResistorB6.class) {
                            index = ((DefaultComboBoxModel<String>) comboBox_tempC.getModel()).getIndexOf(bands[5]);
                            comboBox_tempC.setSelectedItem(comboBox_tempC.getItemAt(index));
                        }
                    }

                    // Simulate a button click for the "Calculate" button
                    ActionEvent actionEvent = new ActionEvent(btn_calculate, ActionEvent.ACTION_PERFORMED, btn_calculate.getActionCommand());
                    for (ActionListener listener : btn_calculate.getActionListeners()) {
                        listener.actionPerformed(actionEvent);
                    }
                }
            }
        });

        // Adding ActionListeners for the combo boxes to update the color panels
        comboBox_band_1.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                String bandColor = comboBox_band_1.getItemAt(comboBox_band_1.getSelectedIndex()).toString();
                Color newColor = getColor(bandColor);
                panel_band_1.setBackground(newColor);
            }
        });

        comboBox_band_2.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                String bandColor = comboBox_band_2.getItemAt(comboBox_band_2.getSelectedIndex()).toString();
                Color newColor = getColor(bandColor);
                panel_band_2.setBackground(newColor);
            }
        });

        comboBox_band_3.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                String bandColor = comboBox_band_3.getItemAt(comboBox_band_3.getSelectedIndex()).toString();
                Color newColor = getColor(bandColor);
                panel_band_3.setBackground(newColor);
            }
        });

        comboBox_multiplier.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                String bandColor = comboBox_multiplier.getItemAt(comboBox_multiplier.getSelectedIndex()).toString();
                Color newColor = getColor(bandColor);
                panel_multiplier.setBackground(newColor);
            }
        });

        comboBox_tolerance.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                String bandColor = comboBox_tolerance.getItemAt(comboBox_tolerance.getSelectedIndex()).toString();
                Color newColor = getColor(bandColor);
                panel_tolerance.setBackground(newColor);
            }
        });

        comboBox_tempC.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                String bandColor = comboBox_tempC.getItemAt(comboBox_tempC.getSelectedIndex()).toString();
                Color newColor = getColor(bandColor);
                panel_tempC.setBackground(newColor);
            }
        });

        comboBox_chooseBands.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                int selectedIndex = comboBox_chooseBands.getSelectedIndex();
                switch (selectedIndex) {
                    case 0:
                        // 4-band resistor
                        comboBox_band_1.setVisible(true);
                        comboBox_band_2.setVisible(true);
                        comboBox_band_3.setVisible(false);
                        comboBox_multiplier.setVisible(true);
                        comboBox_tolerance.setVisible(true);
                        comboBox_tempC.setVisible(false);

                        lbl_band_1.setVisible(true);
                        lbl_band_2.setVisible(true);
                        lbl_band_3.setVisible(false);
                        lbl_multiplier.setVisible(true);
                        lbl_tolerance.setVisible(true);
                        lbl_tempC.setVisible(false);

                        panel_band_1.setVisible(true);
                        panel_band_2.setVisible(true);
                        panel_band_3.setVisible(false);
                        panel_multiplier.setVisible(true);
                        panel_tolerance.setVisible(true);
                        panel_tempC.setVisible(false);
                        break;
                    case 1:
                        // 5-band resistor
                        comboBox_band_1.setVisible(true);
                        comboBox_band_2.setVisible(true);
                        comboBox_band_3.setVisible(true);
                        comboBox_multiplier.setVisible(true);
                        comboBox_tolerance.setVisible(true);
                        comboBox_tempC.setVisible(false);

                        lbl_band_1.setVisible(true);
                        lbl_band_2.setVisible(true);
                        lbl_band_3.setVisible(true);
                        lbl_multiplier.setVisible(true);
                        lbl_tolerance.setVisible(true);
                        lbl_tempC.setVisible(false);

                        panel_band_1.setVisible(true);
                        panel_band_2.setVisible(true);
                        panel_band_3.setVisible(true);
                        panel_multiplier.setVisible(true);
                        panel_tolerance.setVisible(true);
                        panel_tempC.setVisible(false);
                        break;
                    case 2:
                        // 6-band resistor
                        comboBox_band_1.setVisible(true);
                        comboBox_band_2.setVisible(true);
                        comboBox_band_3.setVisible(true);
                        comboBox_multiplier.setVisible(true);
                        comboBox_tolerance.setVisible(true);
                        comboBox_tempC.setVisible(true);

                        lbl_band_1.setVisible(true);
                        lbl_band_2.setVisible(true);
                        lbl_band_3.setVisible(true);
                        lbl_multiplier.setVisible(true);
                        lbl_tolerance.setVisible(true);
                        lbl_tempC.setVisible(true);

                        panel_band_1.setVisible(true);
                        panel_band_2.setVisible(true);
                        panel_band_3.setVisible(true);
                        panel_multiplier.setVisible(true);
                        panel_tolerance.setVisible(true);
                        panel_tempC.setVisible(true);
                        break;
                }
            }
        });
    }

    /**
     * Returns a Color object corresponding to the given band color name.
     *
     * @param bandColor the name of the band color (case-sensitive).
     *                  Valid colors are: "Black", "Brown", "Red", "Orange", "Yellow",
     *                  "Green", "Blue", "Violet", "Gray", "White", "Gold", "Silver".
     * @return a Color object representing the RGB color value of the band.
     *         If an invalid band color is provided, returns Color(0) (black color).
     */
    Color getColor(String bandColor){
        Color color = new Color(0);

        switch (bandColor){
            case "Black": color = new Color(0x1D1C1A); break;
            case "Brown": color = new Color(0x653A19); break;
            case "Red": color = new Color(0xD23019); break;
            case "Orange": color = new Color(0xEF8619); break;
            case "Yellow": color = new Color(0xEED319); break;
            case "Green": color = new Color(0x19AC2F); break;
            case "Blue": color = new Color(0x198FD0); break;
            case "Violet": color = new Color(0xA640D0); break;
            case "Gray": color = new Color(0xA5A5A5); break;
            case "White": color = new Color(0xFDFDFD); break;
            case "Gold": color = new Color(0xFDEC90); break;
            case "Silver": color = new Color(0xDBDBDB); break;
        }

        return color;
    }
}
