//
// SSDT-TEMP.dsl
//
// Dell XPS 13 9360, the-darkvoid
//
// Would not have been possible without the work of RehabMan.
// https://github.com/RehabMan/OS-X-Clover-Laptop-Config
//

DefinitionBlock ("", "SSDT", 2, "hack", "TEMP", 0x00000000)
{
    External (ECRB, MethodObj) // Embedded controller - Read byte
    External (ECWB, MethodObj) // Embedded controller - Write byte

    Device (SMCD) // ACPISensors virtual device
    {
        Name (_HID, "MON00000") // _HID: Hardware ID

        Mutex (SMCX, 0x00)

        // Note that only devices names as defined in xxxx are allowed.
        // https://github.com/RehabMan/OS-X-FakeSMC-kozlek/blob/master/FakeSMCKeyStore/FakeSMCPlugin.cpp#L38
        Name (TEMP, Package()
        {
            // B0D4._TMP - 8086_1903
            "CPU Heatsink", "TCPU",
            // SEN1._TMP - FAN1
            "CPU Proximity", "TFN1",
            // GEN1._TMP - FAN2
            "Mainboard", "TFN2",
            // SEN2._TMP - SSD HT4
            "PCH Proximity", "TSSD",
            // TMEM._TMP - Memory Temperature Sensor (HT1)
            "Memory Module", "TMEM",
        })

        // Query embedded controller for data
        Method (ECQR, 3, Serialized)
        {
            Acquire (SMCX, 0xFFFF)

            If (Arg0 > Zero)
            {
                \ECWB(Arg0, Arg2)
            }
            Local0 = Zero

            If (Arg1 > 0)
            {
                Local0 = \ECRB(Arg1)
            }

            Release (SMCX)

            If (Local0 >= 0x80)
            {
                Local0 = Zero
            }

            Return (Local0)
        }

        Method (TCPU, 0, Serialized)
        {
            // B0D4._TMP
            Local0 = ECQR(0x33, 0x34, 0x00)
            Return (Local0)
        }

        Method (TFN1, 0, Serialized)
        {
            // SEN1._TMP
            Local0 = ECQR(0x33, 0x34, 0x01)
            Return (Local0)
        }

        Method (TFN2, 0, Serialized)
        {
            // GEN1._TMP
            Local0 = ECQR(0x33, 0x34, 0x02)
            Return (Local0)
        }

        Method (TSSD, 0, Serialized)
        {
            // SEN2._TMP
            Local0 = ECQR(0x33, 0x34, 0x03)
            Return (Local0)       
        }

        Method (TMEM, 0, Serialized)
        {
            // TMEM._TMP
            Local0 = ECQR(0x33, 0x34, 0x04)
            Return (Local0)               
        }
    }
}