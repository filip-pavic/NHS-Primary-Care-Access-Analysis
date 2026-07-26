# DAX Measures — London GP Appointment & Access Overview (May 2026)

Measures used to look at how GP appointments are delivered and how quickly patients are seen, across London practices.

---

### Remote Delivery %
```dax
Remote Delivery % = 
VAR RemoteAppts = CALCULATE(SUM(Summary_Delivery_Mode[total_appointments]), Summary_Delivery_Mode[appt_mode] IN {"Telephone", "Video Conference/Online"})
VAR TotalAppts = SUM(Summary_Delivery_Mode[total_appointments])
RETURN DIVIDE(RemoteAppts, TotalAppts, 0)
```
Share of appointments delivered remotely (phone or video/online) out of all appointments. `DIVIDE` handles the zero-denominator case cleanly.

### Same Day Rate %
```dax
Same Day Rate % = 
VAR SameDayAppts = CALCULATE(SUM(Summary_Wait_Times[total_appointments]), Summary_Wait_Times[time_between_booking_and_appt] = "Same Day")
VAR TotalAppts = SUM(Summary_Wait_Times[total_appointments])
RETURN DIVIDE(SameDayAppts, TotalAppts, 0)
```
Share of appointments booked and seen on the same day, out of all appointments. Same pattern as above — filter to the relevant slice, then divide by the total.
