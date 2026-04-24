{% docs interviews %}
An interview moves through a series of steps such as requested, scheduled, in progress, waiting for feedback and completed.  
These steps help show where the interview is in the hiring process and allow us to measure how long each part takes.
{% enddocs %}

{% docs row_valid_from %}
`row_valid_from` shows when a specific version of a record became valid.  
It marks the beginning of the time period during which that version was active.
{% enddocs %}

{% docs row_valid_to %}
`row_valid_to` shows when a specific version of a record stopped being valid.  
If this value is empty it means the version is currently active.
{% enddocs %}

{% docs fct_interview_definition %}
The interview fact table contains one row per interview.  
It combines the latest interview details with important timestamps from the interview history such as when it was scheduled, started, finished and completed.  
It also links the interview to the candidate and interviewer details that were valid when the interview was first created.
{% enddocs %}

{% docs candidates %}
A candidate is a person going through the hiring process.  
Candidate records describe their skill, job family, staffing status and language level.
{% enddocs %}

{% docs employees %}
An employee is a person inside the company who can take part in interviews.  
Employee records describe their role, organization, work dates and employment status.
{% enddocs %}

{% docs latest_staging_model_definition %}
latest staging model keeps only the most current version of each business record.  
It is useful when downstream models need one row per business entity instead of full history.
{% enddocs %}