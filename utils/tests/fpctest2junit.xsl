<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml" indent="yes" />
	<xsl:template match="/">
		<testsuites>
			<xsl:variable name="buildName" select="//TestListing/TestSuite/TestSuite/@Name"/>
                        <xsl:variable name="numberOfTests" select="//TestListing/TestSuite/@NumberOfRunTests"/>
			<xsl:variable name="numberOfFailures" select="//TestListing/TestSuite/@NumberOfFailures"/>
            <xsl:variable name="elapsedHour" select="format-time(//TestListing/TestSuite/@ElapsedTime, '[H]')"/>
            <xsl:variable name="elapsedMin" select="format-time(//TestListing/TestSuite/@ElapsedTime, '[m01]')"/>
            <xsl:variable name="elapsedSecond" select="format-time(//TestListing/TestSuite/@ElapsedTime, '[s1].[f001]')"/>
			<xsl:variable name="elapsedTime" select="number($elapsedHour)*3600+number($elapsedMin)*60+number($elapsedSecond)"/>
			<xsl:variable name="numberOfErrors" select="//TestListing/TestSuite/@NumberOfErrors"/>
			<xsl:variable name="numberOfIgnoredTests" select="//TestListing/TestSuite/@NumberOfIgnoredTests"/>
			<testsuite name="{$buildName}" tests="{$numberOfTests}" time="{$elapsedTime}" failures="{$numberOfFailures}" errors="{$numberOfErrors}" skipped="{$numberOfIgnoredTests}">
			<xsl:for-each select="//TestListing/TestSuite/TestSuite/Test">
					<xsl:variable name="testName" select="@Name"/>
					<xsl:variable name="elapsedH" select="format-time(@ElapsedTime, '[H]')"/>
					<xsl:variable name="elapsedM" select="format-time(@ElapsedTime, '[m01]')"/>
					<xsl:variable name="elapsedS" select="format-time(@ElapsedTime, '[s1].[f001]')"/>
					<xsl:variable name="duration" select="number($elapsedH)*3600+number($elapsedM)*60+number($elapsedS)"/>
					<xsl:variable name="status" select="@Result"/>
					<xsl:variable name="output" select="Results/Measurement/Value"/>
					<xsl:variable name="className" select="translate(Path, '/.', '.')"/>
					<testcase classname="{$buildName}-{$testName}"
						name="{$testName}"
						time="{$duration}">
						<xsl:if test="@Result!='OK'">
							<failure>
								<xsl:value-of select="$status" />
							</failure>
						</xsl:if>
						<system-out>
							<xsl:value-of select="$status" />
						</system-out>
					</testcase>
				</xsl:for-each>
			</testsuite>
		</testsuites>
	</xsl:template>
</xsl:stylesheet>